require "test_helper"

class AuthenticationTest < ActiveSupport::TestCase
  setup do
    [ AuditEvent, Session, Identity, AccessGrant, User ].each(&:delete_all)
  end

  test "unauthorized unverified and wrong-domain attempts create nothing" do
    create_user("owner@example.test", role: :owner)

    with_domains("allowed.test") do
      assert_raises(GoogleAuthenticator::Denied) { GoogleAuthenticator.call!(auth("nobody@allowed.test", "allowed.test")) }
      assert_raises(GoogleAuthenticator::Denied) { GoogleAuthenticator.call!(auth("person@wrong.test", "wrong.test")) }
      assert_raises(GoogleAuthenticator::Denied) { GoogleAuthenticator.call!(auth("person@allowed.test", "allowed.test", verified: false)) }
    end

    assert_equal [ "owner@example.test" ], User.pluck(:email_address)
    assert_equal 0, Identity.count
    assert_equal 0, Session.count
  end

  test "a granted verified identity binds immutable subject and creates a digested session" do
    owner, = create_user("owner@example.test", role: :owner)
    grant = AccessGrant.create!(normalized_email: "person@allowed.test", granted_by: owner, granted_at: Time.current)

    with_domains("allowed.test") do
      user, session, raw = GoogleAuthenticator.call!(auth("person@allowed.test", "allowed.test"))
      assert_equal "stable-sub", user.identities.first.provider_subject
      assert_equal user, grant.reload.claimed_by
      assert_equal session.token_digest, TokenDigest.call(raw)

      returning_user, = GoogleAuthenticator.call!(auth("renamed@allowed.test", "allowed.test"))
      assert_equal user, returning_user
      assert_raises(GoogleAuthenticator::Denied) { GoogleAuthenticator.call!(auth("person@allowed.test", "allowed.test", subject: "changed-sub")) }
    end
  end

  test "owner transfer, revocation, audit immutability, and production agent guard hold" do
    owner, = create_user("owner@example.test", role: :owner)
    member, grant = create_user("member@example.test", granted_by: owner)
    session, = Session.issue!(user: member)

    grant.revoke!(actor: owner)
    assert session.reload.revoked_at
    grant.update!(active: true, revoked_at: nil, revoked_by: nil)
    OwnershipTransfer.call!(actor: owner, recipient: member)
    assert_equal 1, User.owner.where(active: true).count

    event = AuditEvent.record!(actor: member, action: "test.recorded", subject: member)
    assert_raises(ActiveRecord::ReadonlyAttributeError) { event.update!(action: "changed") }
    refute AgentSessionsController.available?("production")
  end

  private
    def create_user(email, role: :member, granted_by: nil)
      user = User.create!(email_address: email, name: "Test", role:)
      grant = AccessGrant.create!(normalized_email: email, granted_by: granted_by || user, granted_at: Time.current, claimed_by: user, claimed_at: Time.current)
      [ user, grant ]
    end

    def auth(email, domain, verified: true, subject: "stable-sub")
      {
        "uid" => subject,
        "info" => { "email" => email, "name" => "Person", "email_verified" => verified },
        "extra" => { "id_info" => { "hd" => domain, "email_verified" => verified } }
      }
    end

    def with_domains(domains)
      original = ENV["GOOGLE_WORKSPACE_DOMAINS"]
      ENV["GOOGLE_WORKSPACE_DOMAINS"] = domains
      yield
    ensure
      ENV["GOOGLE_WORKSPACE_DOMAINS"] = original
    end
end
