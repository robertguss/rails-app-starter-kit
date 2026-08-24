# frozen_string_literal: true

# A complete resumable integration slice over the fixture adapter.

module Integrations
  module FixtureProvider
    class Importer
      def initialize(operation:, worker_id:, client:)
        @operation = operation
        @worker_id = worker_id
        @client = client
      end

      def call
        records = @client.records
        create_items(records)
        update_progress("applying records")

        @operation.items.where(status: "pending").order(:id).each do |item|
          process(item, records.index_by(&:id).fetch(item.external_key))
          update_progress("applying records")
        end

        counts = @operation.items.group(:status).count
        status = counts["failed"].to_i.positive? ? "partially_succeeded" : "succeeded"
        @operation.finish!(status:, result_summary: counts, worker_id: @worker_id)
        AuditEvent.record!(actor: @operation.actor, action: "operation.#{status}", subject: @operation, metadata: counts)
      end

      private
        def create_items(records)
          records.each do |record|
            @operation.items.find_or_create_by!(external_key: record.id) do |item|
              item.input_summary = { name: record.name, state: record.state }
            end
          end
        end

        def process(item, record)
          delay = ProviderPace.reserve!(
            key: "fixture-provider",
            interval: ENV.fetch("FIXTURE_PROVIDER_MINIMUM_INTERVAL", "0").to_f
          )
          sleep(delay) if delay.positive?
          result = @client.update(record, idempotency_key: "operation/#{@operation.id}/item/#{item.id}")
          item.succeed!(summary: { provider_id: result.provider_id, outcome: result.outcome })
        rescue AmbiguousWrite => error
          item.fail!(category: "ambiguous_write", message: error.message)
        rescue PermanentError => error
          item.fail!(category: error.class.name, message: error.message)
        end

        def update_progress(step)
          @operation.record_progress!(
            current: @operation.items.where.not(status: "pending").count,
            total: @operation.items.count,
            step:,
            worker_id: @worker_id
          )
        end
    end
  end
end
