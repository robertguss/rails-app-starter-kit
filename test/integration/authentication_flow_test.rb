require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup do
    [ AuditEvent, PasswordRecovery, Invitation, Session, Identity, AccessGrant, User ].each(&:delete_all)
    @owner = User.create!(email_address: "owner@example.test", name: "Owner", password: "long-password", role: :owner)
    AccessGrant.create!(normalized_email: @owner.email_address, granted_by: @owner, granted_at: Time.current, claimed_by: @owner, claimed_at: Time.current)
  end

  test "application pages require authentication" do
    get root_path

    assert_redirected_to login_path(return_to: "/")
  end

  test "password login succeeds and external return is rejected" do
    post login_path, params: { email_address: @owner.email_address, password: "long-password", return_to: "https://evil.test" }
    assert_redirected_to root_path
    assert_equal 1, Session.count
  end

  test "unknown password user cannot enroll" do
    post login_path, params: { email_address: "unknown@example.test", password: "anything" }
    assert_redirected_to login_path
    assert_equal 1, User.count
  end

  test "non-owner cannot manage access" do
    member = User.create!(email_address: "member@example.test", name: "Member", password: "long-password")
    AccessGrant.create!(normalized_email: member.email_address, granted_by: @owner, granted_at: Time.current, claimed_by: member, claimed_at: Time.current)
    post login_path, params: { email_address: member.email_address, password: "long-password" }
    get settings_access_path
    assert_response :forbidden
  end

  test "revoking access invalidates an existing browser session" do
    member = User.create!(email_address: "member@example.test", name: "Member", password: "long-password")
    grant = AccessGrant.create!(normalized_email: member.email_address, granted_by: @owner, granted_at: Time.current, claimed_by: member, claimed_at: Time.current)
    post login_path, params: { email_address: member.email_address, password: "long-password" }
    assert_redirected_to root_path

    grant.revoke!(actor: @owner)
    get root_path

    assert_redirected_to login_path(return_to: "/")
  end

  test "password routes are absent when password authentication is disabled" do
    with_auth_methods("google") do
      post login_path, params: { email_address: @owner.email_address, password: "long-password" }
      assert_response :not_found

      get new_password_recovery_path
      assert_response :not_found

      get invitation_path("unknown")
      assert_response :not_found
    end
    assert_equal 0, Session.count
  end

  test "agent login accepts only deterministic fixtures" do
    previous = AgentSessionsController.environment_guard
    AgentSessionsController.environment_guard = -> { "development" }
    post agent_login_path, params: { user: "owner", return_to: "/settings/access" }
    assert_redirected_to settings_access_path
    assert_equal @owner, Session.last.user

    delete logout_path
    post agent_login_path, params: { user: @owner.email_address }
    assert_response :not_found
    assert_equal 1, Session.count
  ensure
    AgentSessionsController.environment_guard = previous
  end

  test "agent login is 404 under production guard" do
    previous = AgentSessionsController.environment_guard
    AgentSessionsController.environment_guard = -> { "production" }
    post agent_login_path, params: { user: "owner" }
    assert_response :not_found
    assert_equal 0, Session.count
  ensure
    AgentSessionsController.environment_guard = previous
  end

  test "granting access queues an invitation only when mail delivery is configured" do
    previous = Rails.configuration.x.mail_delivery_enabled
    post login_path, params: { email_address: @owner.email_address, password: "long-password" }

    assert_enqueued_emails 1 do
      post settings_access_path, params: { email: "invited@example.test" }
    end
    assert_equal 1, Invitation.count

    Rails.configuration.x.mail_delivery_enabled = false
    assert_no_enqueued_emails do
      post settings_access_path, params: { email: "operator-delivered@example.test" }
    end
    assert_equal 1, Invitation.count
  ensure
    Rails.configuration.x.mail_delivery_enabled = previous unless previous.nil?
  end

  private
    def with_auth_methods(methods)
      original = ENV["AUTH_METHODS"]
      ENV["AUTH_METHODS"] = methods
      yield
    ensure
      ENV["AUTH_METHODS"] = original
    end
end
