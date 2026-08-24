# frozen_string_literal: true

require "test_helper"

class IntegrationOperationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    [ OperationItem, Operation, ProviderPace, AuditEvent, Session, Identity, AccessGrant, User ].each(&:delete_all)
    @owner = create_user("owner@example.test", role: :owner)
  end

  test "safe HTTP boundary rejects insecure targets and classifies fixture failures" do
    assert_raises(Integrations::ConfigurationError) do
      Integrations::HttpClient.new(base_url: "http://provider.example.test")
    end
    assert_raises(Integrations::InvalidResponse) do
      Integrations::FixtureProvider::Parser.page('{"records":"not-an-array"}')
    end
    assert_raises(Integrations::Timeout) do
      Integrations::FixtureProvider::Factory.build(simulation: "timeout").records
    end
    assert_raises(Integrations::AuthenticationError) do
      Integrations::FixtureProvider::Factory.build(simulation: "authentication_failure").records
    end
    assert_raises(Integrations::RateLimited) do
      Integrations::FixtureProvider::Factory.build(simulation: "rate_limited").records
    end
  end

  test "successful fixture operation pages records and completes every item" do
    operation = operation_for("success")

    FixtureImportJob.perform_now(operation.id)

    assert_equal "succeeded", operation.reload.status
    assert_equal 3, operation.progress_current
    assert_equal 3, operation.progress_total
    assert_equal %w[succeeded succeeded succeeded], operation.items.order(:id).pluck(:status)
    assert_equal({ "succeeded" => 3 }, operation.result_summary)
    assert AuditEvent.exists?(action: "operation.succeeded", subject_id: operation.id)
  end

  test "transient failures schedule a bounded job retry and terminal protocol failures stop" do
    transient = operation_for("timeout")
    assert_enqueued_jobs 1, only: FixtureImportJob do
      FixtureImportJob.perform_now(transient.id)
    end
    assert_equal "running", transient.reload.status

    terminal = operation_for("invalid_response")
    FixtureImportJob.perform_now(terminal.id)
    assert_equal "failed", terminal.reload.status
    assert_equal "Integrations::InvalidResponse", terminal.error_category
  end

  test "partial and ambiguous writes are terminal per-item failures without unsafe retry" do
    partial = operation_for("partial_success")
    FixtureImportJob.perform_now(partial.id)
    assert_equal "partially_succeeded", partial.reload.status
    assert_equal({ "failed" => 1, "succeeded" => 2 }, partial.result_summary)

    ambiguous = operation_for("ambiguous_write")
    FixtureImportJob.perform_now(ambiguous.id)
    assert_equal "partially_succeeded", ambiguous.reload.status
    assert_equal "ambiguous_write", ambiguous.items.find_by!(external_key: "record-1").error_category
  end

  test "a successfully reconciled item clears its previous failure metadata" do
    operation = operation_for("success")
    item = operation.items.create!(external_key: "retryable")
    item.fail!(category: "timeout", message: "Provider timed out")

    item.succeed!(summary: { outcome: "reconciled" })

    assert_equal "succeeded", item.status
    assert_equal({ "outcome" => "reconciled" }, item.result_summary)
    assert_nil item.error_category
    assert_nil item.error_message
  end

  test "an interrupted operation retains its claim and resumes only after it is stale" do
    operation = operation_for("interruption")

    assert_raises(Integrations::FixtureProvider::SimulatedInterruption) do
      FixtureImportJob.perform_now(operation.id)
    end
    assert_equal "running", operation.reload.status
    assert_equal 1, operation.items.where(status: "succeeded").count
    refute operation.claim!(worker_id: "other-worker", now: operation.heartbeat_at + 1.minute)

    operation.update!(request_summary: { simulation: "success" }, heartbeat_at: 10.minutes.ago)
    FixtureImportJob.perform_now(operation.id)

    assert_equal "succeeded", operation.reload.status
    assert_equal 3, operation.items.where(status: "succeeded").count
  end

  test "idempotency is durable and keys cannot cross actors" do
    first, created = Operation.create_idempotent!(actor: @owner, kind: "fixture_import", idempotency_key: "same-key")
    duplicate, duplicate_created = Operation.create_idempotent!(actor: @owner, kind: "fixture_import", idempotency_key: "same-key")

    assert created
    refute duplicate_created
    assert_equal first, duplicate

    member = create_user("member@example.test", granted_by: @owner)
    assert_raises(Integrations::Conflict) do
      Operation.create_idempotent!(actor: member, kind: "fixture_import", idempotency_key: "same-key")
    end
  end

  test "PostgreSQL pacing is shared and persisted" do
    now = Time.current
    assert_equal 0, ProviderPace.reserve!(key: "provider", interval: 2, now:)
    assert_in_delta 2, ProviderPace.reserve!(key: "provider", interval: 2, now:), 0.001
    assert_equal 1, ProviderPace.where(key: "provider").count
  end

  test "stored errors and structured HTTP logs redact secrets" do
    operation = operation_for("success")
    operation.fail!(category: "configuration", message: "token=top-secret password=hunter2")
    refute_includes operation.error_message, "top-secret"
    refute_includes operation.error_message, "hunter2"
    assert_includes operation.error_message, "[FILTERED]"

    output = StringIO.new
    original_logger = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(output)
    Integrations::FixtureProvider::Factory.build.records
    refute_includes output.string, "fixture"
    refute_includes output.string, "Authorization"
  ensure
    Rails.logger = original_logger
  end

  private
    def operation_for(simulation)
      Operation.create!(actor: @owner, kind: "fixture_import", request_summary: { simulation: })
    end

    def create_user(email, role: :member, granted_by: nil)
      user = User.create!(email_address: email, name: email.split("@").first.titleize, role:)
      AccessGrant.create!(
        normalized_email: email,
        granted_by: granted_by || user,
        granted_at: Time.current,
        claimed_by: user,
        claimed_at: Time.current
      )
      user
    end
end
