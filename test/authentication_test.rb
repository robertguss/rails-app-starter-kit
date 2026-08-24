require "test_helper"

class AuthenticationTest < ActiveSupport::TestCase
  setup do
    [ AuditEvent, PasswordRecovery, Invitation, Session, Identity, AccessGrant, User ].each(&:delete_all)
  end

  test "session stores only a digest and requires active access" do
    create_user("owner@example.test", role: :owner)
    user, grant = create_user("member@example.test")
    session, raw = Session.issue!(user:)

    refute_equal raw, session.token_digest
    refute_includes session.attributes.to_json, raw
    assert_equal session, Session.find_by(token_digest: TokenDigest.call(raw))
    assert session.live?

    grant.update!(active: false, revoked_at: Time.current)
    refute session.live?
  end

  test "invitation is rotating single use enrollment" do
    owner, = create_user("owner@example.test", role: :owner)
    grant = AccessGrant.create!(normalized_email: "invite@example.test", granted_by: owner, granted_at: Time.current)
    old, = TokenIssuer.issue!(grant.invitations)
    invitation, raw = TokenIssuer.issue!(grant.invitations)

    assert old.reload.revoked_at
    refute_includes invitation.attributes.to_json, raw
    user, session, session_token = InvitationAcceptance.call!(
      token: raw,
      name: "Invitee",
      password: "long-enough-password",
      password_confirmation: "long-enough-password"
    )

    assert_equal user, grant.reload.claimed_by
    assert invitation.reload.consumed_at
    assert_equal session.token_digest, TokenDigest.call(session_token)
    assert_not invitation.update(consumed_at: nil)
    assert_raises(ActiveRecord::RecordNotFound) do
      InvitationAcceptance.call!(token: raw, name: "Thief", password: "another-long-password")
    end
  end

  test "unknown expired and mismatched-confirmation invitations create nothing" do
    owner, = create_user("owner@example.test", role: :owner)
    grant = AccessGrant.create!(normalized_email: "granted@example.test", granted_by: owner, granted_at: Time.current)

    assert_raises(ActiveRecord::RecordNotFound) do
      InvitationAcceptance.call!(token: "unknown", name: "X", password: "long-enough-password")
    end

    invitation, raw = TokenIssuer.issue!(grant.invitations, ttl: 1.second)
    assert_raises(ActiveRecord::RecordInvalid) do
      InvitationAcceptance.call!(
        token: raw,
        name: "X",
        password: "long-enough-password",
        password_confirmation: "different-password"
      )
    end
    assert invitation.reload.consumed_at.nil?
    assert_nil grant.reload.claimed_by
    assert_nil User.find_by(email_address: "granted@example.test")

    travel 2.seconds do
      assert_raises(ActiveRecord::RecordNotFound) do
        InvitationAcceptance.call!(token: raw, name: "X", password: "long-enough-password")
      end
    end
  end

  test "recovery is rotating single use validates confirmation and revokes sessions" do
    create_user("owner@example.test", role: :owner)
    user, = create_user("recover@example.test")
    session, = Session.issue!(user:)
    old, = TokenIssuer.issue!(user.password_recoveries)
    recovery, raw = TokenIssuer.issue!(user.password_recoveries)

    assert old.reload.revoked_at
    assert_raises(ActiveRecord::RecordInvalid) do
      PasswordRecoveryService.reset!(token: raw, password: "changed-password", password_confirmation: "different-password")
    end
    assert recovery.reload.consumed_at.nil?
    assert session.reload.live?

    PasswordRecoveryService.reset!(token: raw, password: "changed-password", password_confirmation: "changed-password")
    assert recovery.reload.consumed_at
    assert session.reload.revoked_at
    assert user.reload.authenticate("changed-password")
    assert_raises(ActiveRecord::RecordNotFound) do
      PasswordRecoveryService.reset!(token: raw, password: "another-password")
    end
  end

  test "unauthorized unverified and wrong-domain Google attempts create nothing" do
    create_user("owner@example.test", role: :owner)

    with_google_domains("allowed.test") do
      assert_raises(GoogleAuthenticator::Denied) { GoogleAuthenticator.call!(google_auth("nobody@allowed.test", "allowed.test")) }
      assert_raises(GoogleAuthenticator::Denied) { GoogleAuthenticator.call!(google_auth("person@wrong.test", "wrong.test")) }
      assert_raises(GoogleAuthenticator::Denied) { GoogleAuthenticator.call!(google_auth("person@allowed.test", "allowed.test", verified: false)) }
    end

    assert_equal [ "owner@example.test" ], User.pluck(:email_address)
    assert_equal 0, Identity.count
    assert_equal 0, Session.count
  end

  test "granted verified Google creates a transactional session and binds immutable subject" do
    owner, = create_user("owner@example.test", role: :owner)
    grant = AccessGrant.create!(normalized_email: "person@allowed.test", granted_by: owner, granted_at: Time.current)

    with_google_domains("allowed.test") do
      user, session, raw = GoogleAuthenticator.call!(google_auth("person@allowed.test", "allowed.test"))
      assert_equal "stable-sub", user.identities.first.provider_subject
      assert_equal user, grant.reload.claimed_by
      assert_equal session.token_digest, TokenDigest.call(raw)

      returning_user, = GoogleAuthenticator.call!(google_auth("renamed@allowed.test", "allowed.test"))
      assert_equal user, returning_user

      assert_raises(GoogleAuthenticator::Denied) do
        GoogleAuthenticator.call!(google_auth("person@allowed.test", "allowed.test", subject: "changed-sub"))
      end
    end
  end

  test "revocation invalidates sessions and the owner cannot be revoked" do
    owner, owner_grant = create_user("owner@example.test", role: :owner)
    member, grant = create_user("member@example.test")
    session, = Session.issue!(user: member)

    grant.revoke!(actor: owner)
    assert session.reload.revoked_at
    assert_raises(ActiveRecord::RecordInvalid) { owner_grant.revoke!(actor: owner) }
  end

  test "the last owner cannot be demoted deactivated destroyed or revoked" do
    owner, grant = create_user("owner@example.test", role: :owner)

    assert_not owner.update(role: :member)
    assert_not owner.update(active: false)
    assert_not owner.destroy
    assert_raises(ActiveRecord::RecordInvalid) { grant.revoke!(actor: owner) }

    assert owner.reload.owner?
    assert owner.active?
    assert grant.reload.active?
  end

  test "ownership transfer keeps one owner and revokes both users sessions" do
    owner, = create_user("owner@example.test", role: :owner)
    member, = create_user("member@example.test")
    owner_session, = Session.issue!(user: owner)
    member_session, = Session.issue!(user: member)

    OwnershipTransfer.call!(actor: owner, recipient: member)

    assert member.reload.owner?
    assert owner.reload.member?
    assert_equal 1, User.owner.where(active: true).count
    assert owner_session.reload.revoked_at
    assert member_session.reload.revoked_at
    assert AuditEvent.exists?(action: "owner.transferred", actor: owner, subject_id: member.id)
  end

  test "the database rejects bypassing the exactly one usable owner invariant" do
    owner, grant = create_user("owner@example.test", role: :owner)

    assert_raises ActiveRecord::StatementInvalid do
      User.transaction(requires_new: true) do
        owner.update_columns(role: "member")
        ApplicationRecord.connection.execute("SET CONSTRAINTS ALL IMMEDIATE")
      end
    end
    assert owner.reload.owner?

    assert_raises ActiveRecord::StatementInvalid do
      AccessGrant.transaction(requires_new: true) do
        grant.update_columns(active: false, revoked_at: Time.current)
        ApplicationRecord.connection.execute("SET CONSTRAINTS ALL IMMEDIATE")
      end
    end
    assert grant.reload.active?
  end

  test "audit events are immutable" do
    owner, = create_user("owner@example.test", role: :owner)
    event = AuditEvent.record!(actor: owner, action: "test.recorded", subject: owner)

    assert_raises(ActiveRecord::ReadonlyAttributeError) { event.update!(action: "changed") }
    assert_raises(ActiveRecord::ReadOnlyRecord) { event.destroy! }
    assert_raises(ActiveRecord::StatementInvalid) do
      AuditEvent.transaction(requires_new: true) do
        ApplicationRecord.connection.exec_update("UPDATE audit_events SET action = 'bypassed' WHERE id = #{event.id}")
      end
    end
  end

  test "return paths and production agent guard are negative" do
    assert_equal "/inside?q=1", Authentication.internal_path("/inside?q=1")
    assert_equal "/", Authentication.internal_path("https://evil.test/steal")
    assert_equal "/", Authentication.internal_path("//evil.test/steal")
    refute AgentSessionsController.available?("production")
  end

  private
    def create_user(email, role: :member)
      user = User.create!(
        email_address: email,
        name: "Test",
        password: "long-enough-password",
        password_confirmation: "long-enough-password",
        role:
      )
      grant = AccessGrant.create!(
        normalized_email: email,
        granted_by: user,
        granted_at: Time.current,
        claimed_by: user,
        claimed_at: Time.current
      )
      [ user, grant ]
    end

    def google_auth(email, hd, verified: true, subject: "stable-sub")
      {
        "uid" => subject,
        "info" => { "email" => email, "name" => "Person", "email_verified" => verified },
        "extra" => { "id_info" => { "hd" => hd, "email_verified" => verified } }
      }
    end

    def with_google_domains(domains)
      original = ENV["GOOGLE_WORKSPACE_DOMAINS"]
      ENV["GOOGLE_WORKSPACE_DOMAINS"] = domains
      yield
    ensure
      ENV["GOOGLE_WORKSPACE_DOMAINS"] = original
    end
end
