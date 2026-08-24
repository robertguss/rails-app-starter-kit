require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup do
    [ AuditEvent, PasswordRecovery, Invitation, Session, Identity, AccessGrant, User ].each(&:delete_all)
    @owner = User.create!(email_address: "owner@example.test", name: "Owner", password: "long-password", role: :owner)
    AccessGrant.create!(normalized_email: @owner.email_address, granted_by: @owner, granted_at: Time.current, claimed_by: @owner, claimed_at: Time.current)
  end

  test "closed application rejects unknown enrollment and external return paths" do
    get root_path
    assert_redirected_to login_path(return_to: "/")

    post login_path, params: { email_address: "unknown@example.test", password: "long-password" }
    assert_equal 1, User.count

    post login_path, params: { email_address: @owner.email_address, password: "long-password", return_to: "https://evil.test" }
    assert_redirected_to root_path
  end

  test "member cannot administer access and revocation ends the session" do
    member = User.create!(email_address: "member@example.test", name: "Member", password: "long-password")
    grant = AccessGrant.create!(normalized_email: member.email_address, granted_by: @owner, granted_at: Time.current, claimed_by: member, claimed_at: Time.current)
    post login_path, params: { email_address: member.email_address, password: "long-password" }

    get settings_access_path
    assert_response :forbidden
    grant.revoke!(actor: @owner)
    get root_path
    assert_redirected_to login_path(return_to: "/")
  end

  test "agent login is deterministic and absent under the production guard" do
    previous = AgentSessionsController.environment_guard
    AgentSessionsController.environment_guard = -> { "production" }
    post agent_login_path, params: { user: "owner" }
    assert_response :not_found
    assert_equal 0, Session.count
  ensure
    AgentSessionsController.environment_guard = previous
  end
end
