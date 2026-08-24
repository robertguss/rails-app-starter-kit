# frozen_string_literal: true

# In-memory responses exercise success and failure behavior without a network.

module Integrations
  module FixtureProvider
    class Factory
      def self.build(simulation: "success")
        stubs = Faraday::Adapter::Test::Stubs.new
        stub_reads(stubs, simulation)
        stub_writes(stubs, simulation)
        Client.new(http: HttpClient.new(base_url: "https://fixture-provider.test", token: "fixture", adapter: stubs))
      end

      def self.stub_reads(stubs, simulation)
        stubs.get("/records") do |environment|
          raise Faraday::TimeoutError if simulation == "timeout"
          next [ 429, { "Retry-After" => "0" }, "" ] if simulation == "rate_limited"
          next [ 401, json_headers, "" ] if simulation == "authentication_failure"
          next [ 200, json_headers, '{"records":"wrong"}' ] if simulation == "invalid_response"

          if environment.params["cursor"] == "page-2"
            [ 200, json_headers, JSON.generate(records: [ record("record-3", "Gamma", "active") ], next_cursor: nil) ]
          else
            [
              200,
              json_headers,
              JSON.generate(records: [ record("record-1", "Alpha", "active"), record("record-2", "Beta", "paused") ], next_cursor: "page-2")
            ]
          end
        end
      end
      private_class_method :stub_reads

      def self.stub_writes(stubs, simulation)
        stubs.post(%r{\A/records/([^/]+)\z}) do |environment, metadata|
          record_id = metadata.fetch(:match_data)[1]
          raise AmbiguousWrite, "provider write outcome is unknown" if simulation == "ambiguous_write" && record_id == "record-1"
          raise SimulatedInterruption, "fixture worker stopped" if simulation == "interruption" && record_id == "record-2"
          next [ 422, json_headers, "" ] if simulation == "partial_success" && record_id == "record-2"

          idempotency_key = environment.request_headers["Idempotency-Key"]
          raise PermanentRequestError, "fixture write omitted idempotency" if idempotency_key.blank?

          [ 200, json_headers, JSON.generate(provider_id: record_id, outcome: "updated") ]
        end
      end
      private_class_method :stub_writes

      def self.record(id, name, state) = { id:, name:, state: }
      private_class_method :record

      def self.json_headers = { "Content-Type" => "application/json" }
      private_class_method :json_headers
    end
  end
end
