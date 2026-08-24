# frozen_string_literal: true

# Deterministic fake provider used by generated-app verification.

require "cgi"
require "set"

module Integrations
  module FixtureProvider
    class Client
      def initialize(http:)
        @http = http
      end

      def records
        cursor = nil
        seen_cursors = Set.new
        results = []

        loop do
          response = @http.get("/records", params: cursor ? { cursor: } : {})
          page = Parser.page(response.body)
          results.concat(page.records)
          break unless page.next_cursor
          raise InvalidResponse, "provider repeated a pagination cursor" unless seen_cursors.add?(page.next_cursor)

          cursor = page.next_cursor
          raise InvalidResponse, "provider pagination exceeded 100 pages" if seen_cursors.size >= 100
        end

        results
      end

      def update(record, idempotency_key:)
        response = @http.post(
          "/records/#{CGI.escapeURIComponent(record.id)}",
          json: { state: "active" },
          idempotency_key:
        )
        Parser.write(response.body)
      end
    end
  end
end
