# frozen_string_literal: true

# Strict fixture payload parsing mirrors a real adapter boundary.

require "json"

module Integrations
  module FixtureProvider
    Record = Data.define(:id, :name, :state)
    Page = Data.define(:records, :next_cursor)
    WriteResult = Data.define(:provider_id, :outcome)

    class Parser
      def self.page(body)
        payload = object(body)
        records = payload.fetch("records")
        cursor = payload["next_cursor"]
        raise InvalidResponse, "provider records must be an array" unless records.is_a?(Array)
        raise InvalidResponse, "provider cursor must be a string or null" unless cursor.nil? || cursor.is_a?(String)

        Page.new(records: records.map { |record| parse_record(record) }, next_cursor: cursor)
      rescue JSON::ParserError, KeyError
        raise InvalidResponse, "provider returned an invalid records response"
      end

      def self.write(body)
        payload = object(body)
        provider_id = payload.fetch("provider_id")
        outcome = payload.fetch("outcome")
        raise InvalidResponse, "provider write response is invalid" unless provider_id.is_a?(String) && outcome == "updated"

        WriteResult.new(provider_id:, outcome:)
      rescue JSON::ParserError, KeyError
        raise InvalidResponse, "provider returned an invalid write response"
      end

      def self.object(body)
        payload = JSON.parse(body)
        raise InvalidResponse, "provider response must be an object" unless payload.is_a?(Hash)

        payload
      end
      private_class_method :object

      def self.parse_record(payload)
        raise InvalidResponse, "provider record must be an object" unless payload.is_a?(Hash)

        id = payload.fetch("id")
        name = payload.fetch("name")
        state = payload.fetch("state")
        valid = id.is_a?(String) && id.present? && name.is_a?(String) && state.in?(%w[active paused])
        raise InvalidResponse, "provider record fields are invalid" unless valid

        Record.new(id:, name:, state:)
      rescue KeyError
        raise InvalidResponse, "provider record is missing a required field"
      end
      private_class_method :parse_record
    end
  end
end
