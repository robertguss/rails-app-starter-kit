# frozen_string_literal: true

require "test_helper"

class OperationsFlowTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    [ OperationItem, Operation, ProviderPace, AuditEvent, Session, Identity, AccessGrant, User ].each(&:delete_all)
    @owner = create_user("owner@example.test", role: :owner)
    @member = create_user("member@example.test", granted_by: @owner)
    @guard = AgentSessionsController.environment_guard
    AgentSessionsController.environment_guard = -> { "development" }
  end

  teardown do
    AgentSessionsController.environment_guard = @guard
  end

  test "only an owner can view or start operations" do
    post agent_login_path, params: { user: "member" }
    get operations_path
    assert_response :forbidden
    post operations_path
    assert_response :forbidden
  end

  test "duplicate submissions enqueue once and status polling is explicit JSON" do
    post agent_login_path, params: { user: "owner" }

    assert_enqueued_jobs 1, only: FixtureImportJob do
      post operations_path, params: { simulation: "success", idempotency_key: "browser-request" }
      assert_redirected_to operation_path(Operation.last)
      post operations_path, params: { simulation: "success", idempotency_key: "browser-request" }
    end

    assert_equal 1, Operation.count
    get status_operation_path(Operation.last), headers: { "Accept" => "application/json" }
    assert_response :success
    assert_equal "pending", response.parsed_body.dig("operation", "status")
  end

  private
    def create_user(email, role: :member, granted_by: nil)
      user = User.create!(email_address: email, name: email.split("@").first.titleize, role:)
      AccessGrant.create!(normalized_email: email, granted_by: granted_by || user, granted_at: Time.current, claimed_by: user, claimed_at: Time.current)
      user
    end
end
