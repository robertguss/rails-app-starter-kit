# frozen_string_literal: true

class FixtureImportJob < ApplicationJob
  queue_as :integrations
  limits_concurrency to: 1,
    key: ->(operation_id) { "fixture-import-actor-#{Operation.find(operation_id).actor_id}" },
    duration: 15.minutes

  retry_on Integrations::TransientError, wait: :polynomially_longer, attempts: 5 do |job, error|
    operation = Operation.find_by(id: job.arguments.first)
    operation&.fail!(category: error.class.name, message: error.message)
  end

  def perform(operation_id)
    operation = Operation.find(operation_id)
    worker_id = job_id
    return unless operation.claim!(worker_id:)

    Current.operation_id = operation.id
    simulation = operation.request_summary.fetch("simulation", "success")
    client = Integrations::FixtureProvider::Factory.build(simulation:)
    Integrations::FixtureProvider::Importer.new(operation:, worker_id:, client:).call
  rescue Integrations::PermanentError => error
    fail_operation(operation, error)
  rescue Integrations::AmbiguousWrite => error
    fail_operation(operation, error, category: "ambiguous_write")
  ensure
    Current.operation_id = nil
  end

  private
    def fail_operation(operation, error, category: error.class.name)
      return unless operation

      operation.fail!(category:, message: error.message)
      AuditEvent.record!(actor: operation.actor, action: "operation.failed", subject: operation, metadata: { category: })
    end
end
