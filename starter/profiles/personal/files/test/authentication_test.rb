require "test_helper"

class AuthenticationTest < ActiveSupport::TestCase
  setup do
    [ AuditEvent, PasswordRecovery, Invitation, Session, Identity, AccessGrant, User ].each(&:delete_all)
  end

  test "session tokens are digested and revocation invalidates active sessions" do
    owner, = create_user("owner@example.test", role: :owner)
    member, grant = create_user("member@example.test", granted_by: owner)
    session, raw = Session.issue!(user: member)

    refute_equal raw, session.token_digest
    assert session.live?
    grant.revoke!(actor: owner)
    refute session.reload.live?
  end

  test "invitation and recovery tokens rotate and are single use" do
    owner, = create_user("owner@example.test", role: :owner)
    grant = AccessGrant.create!(normalized_email: "invite@example.test", granted_by: owner, granted_at: Time.current)
    invitation, raw = TokenIssuer.issue!(grant.invitations)

    user, = InvitationAcceptance.call!(token: raw, name: "Invitee", password: "long-enough-password")
    assert_equal user, grant.reload.claimed_by
    assert invitation.reload.consumed_at
    assert_raises(ActiveRecord::RecordNotFound) { InvitationAcceptance.call!(token: raw, name: "Again", password: "another-password") }

    recovery, recovery_raw = TokenIssuer.issue!(user.password_recoveries)
    PasswordRecoveryService.reset!(token: recovery_raw, password: "changed-password")
    assert recovery.reload.consumed_at
    assert user.reload.authenticate("changed-password")
    assert_raises(ActiveRecord::RecordNotFound) { PasswordRecoveryService.reset!(token: recovery_raw, password: "another-password") }
  end

  test "owner transfer preserves exactly one usable owner and invalidates sessions" do
    owner, = create_user("owner@example.test", role: :owner)
    member, = create_user("member@example.test", granted_by: owner)
    owner_session, = Session.issue!(user: owner)
    member_session, = Session.issue!(user: member)

    OwnershipTransfer.call!(actor: owner, recipient: member)

    assert_equal 1, User.owner.where(active: true).count
    assert member.reload.owner?
    assert owner_session.reload.revoked_at
    assert member_session.reload.revoked_at
  end

  test "database and model safeguards reject removing the last owner" do
    owner, grant = create_user("owner@example.test", role: :owner)

    assert_not owner.update(role: :member)
    assert_raises ActiveRecord::StatementInvalid do
      User.transaction(requires_new: true) do
        owner.update_columns(role: "member")
        ApplicationRecord.connection.execute("SET CONSTRAINTS ALL IMMEDIATE")
      end
    end
    assert_raises(ActiveRecord::RecordInvalid) { grant.revoke!(actor: owner) }
    assert owner.reload.owner?
  end

  test "audit records and return paths cannot be rewritten or redirected externally" do
    owner, = create_user("owner@example.test", role: :owner)
    event = AuditEvent.record!(actor: owner, action: "test.recorded", subject: owner)

    assert_raises(ActiveRecord::ReadonlyAttributeError) { event.update!(action: "changed") }
    assert_equal "/inside", Authentication.internal_path("/inside")
    assert_equal "/", Authentication.internal_path("https://evil.test/steal")
    refute AgentSessionsController.available?("production")
  end

  private
    def create_user(email, role: :member, granted_by: nil)
      user = User.create!(email_address: email, name: "Test", password: "long-enough-password", role:)
      grant = AccessGrant.create!(normalized_email: email, granted_by: granted_by || user, granted_at: Time.current, claimed_by: user, claimed_at: Time.current)
      [ user, grant ]
    end
end
