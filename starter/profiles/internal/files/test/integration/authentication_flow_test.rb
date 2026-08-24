require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup do
    [ AuditEvent, Session, Identity, AccessGrant, User ].each(&:delete_all)
    @owner = User.create!(email_address: "owner@example.test", name: "Owner", role: :owner)
    AccessGrant.create!(normalized_email: @owner.email_address, granted_by: @owner, granted_at: Time.current, claimed_by: @owner, claimed_at: Time.current)
  end

  test "application pages require authentication and uninstalled password route is absent" do
    get root_path
    assert_redirected_to login_path(return_to: "/")

    post login_path, params: { email_address: @owner.email_address, password: "not-installed" }
    assert_response :not_found
    assert_equal 0, Session.count
  end

  test "non-owner cannot manage access and revocation invalidates a session" do
    member = User.create!(email_address: "member@example.test", name: "Member")
    grant = AccessGrant.create!(normalized_email: member.email_address, granted_by: @owner, granted_at: Time.current, claimed_by: member, claimed_at: Time.current)
    previous = AgentSessionsController.environment_guard
    AgentSessionsController.environment_guard = -> { "development" }
    post agent_login_path, params: { user: "member" }

    get settings_access_path
    assert_response :forbidden
    grant.revoke!(actor: @owner)
    assert_not Session.last.live?
  ensure
    AgentSessionsController.environment_guard = previous
  end

  test "agent login is absent under production guard" do
    previous = AgentSessionsController.environment_guard
    AgentSessionsController.environment_guard = -> { "production" }
    post agent_login_path, params: { user: "owner" }
    assert_response :not_found
  ensure
    AgentSessionsController.environment_guard = previous
  end
end
