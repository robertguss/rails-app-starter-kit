# frozen_string_literal: true

# Shared HTTP safety policy for installed integration adapters.

require "faraday"
require "faraday/retry"
require "json"

module Integrations
  class HttpClient
    Response = Data.define(:status, :headers, :body)
    RETRYABLE_STATUSES = [ 429, 502, 503, 504 ].freeze

    def initialize(base_url:, token: nil, adapter: nil)
      @base_url = validated_base_url(base_url)
      @token = token
      @max_response_bytes = Integer(ENV.fetch("INTEGRATION_MAX_RESPONSE_BYTES", 1_048_576))
      @connection = build_connection(adapter)
    rescue ArgumentError, TypeError
      raise ConfigurationError, "integration HTTP configuration is invalid"
    end

    def get(path, params: {})
      request(:get, path, params:)
    end

    def post(path, json:, idempotency_key:)
      raise ConfigurationError, "external writes require an idempotency key" if idempotency_key.blank?

      request(:post, path, body: JSON.generate(json), headers: {
        "Content-Type" => "application/json",
        "Idempotency-Key" => idempotency_key
      })
    end

    private
      def build_connection(adapter)
        Faraday.new(url: @base_url) do |connection|
          connection.options.open_timeout = Float(ENV.fetch("INTEGRATION_CONNECT_TIMEOUT", 2))
          connection.options.timeout = Float(ENV.fetch("INTEGRATION_READ_TIMEOUT", 10))
          connection.options.write_timeout = Float(ENV.fetch("INTEGRATION_WRITE_TIMEOUT", 10))
          connection.request :retry,
            max: 4,
            interval: 0.25,
            interval_randomness: 0.5,
            backoff_factor: 2,
            methods: [],
            retry_statuses: RETRYABLE_STATUSES,
            retry_if: ->(environment, _exception) {
              environment.method == :get || environment.request_headers["Idempotency-Key"].present?
            }
          adapter ? connection.adapter(:test, adapter) : connection.adapter(Faraday.default_adapter)
        end
      end

      def request(method, path, params: nil, body: nil, headers: {})
        validate_path!(path)
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        response = @connection.run_request(method, path, body, request_headers.merge(headers)) do |request|
          request.params.update(params) if params
        end
        translate_response(response)
      rescue Faraday::TimeoutError
        raise Timeout, "provider request timed out"
      rescue Faraday::ConnectionFailed
        raise Unavailable, "provider is unavailable"
      ensure
        if started
          duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
          Rails.logger.info("integration_http method=#{method} duration_ms=#{(duration * 1000).round} status=#{response&.status || 'error'}")
        end
      end

      def request_headers
        headers = { "Accept" => "application/json" }
        headers["Authorization"] = "Bearer #{@token}" if @token.present?
        headers["X-Request-ID"] = Current.request_id if Current.request_id.present?
        headers["X-Operation-ID"] = Current.operation_id.to_s if Current.operation_id.present?
        headers
      end

      def translate_response(response)
        body = response.body.to_s
        raise InvalidResponse, "provider response exceeded the configured size limit" if body.bytesize > @max_response_bytes

        case response.status
        when 200..299
          Response.new(status: response.status, headers: response.headers.to_h, body:)
        when 401
          raise AuthenticationError, "provider authentication failed"
        when 403
          raise AuthorizationError, "provider authorization failed"
        when 404
          raise NotFound, "provider resource was not found"
        when 409
          raise Conflict, "provider reported a conflict"
        when 429
          raise RateLimited.new(retry_after: retry_after(response.headers["Retry-After"]))
        when 400, 422
          raise ValidationError, "provider rejected invalid data"
        when 500..599
          raise Unavailable, "provider is unavailable"
        else
          raise PermanentRequestError, "provider rejected the request"
        end
      end

      def retry_after(value)
        Float(value) if value.present?
      rescue ArgumentError, TypeError
        nil
      end

      def validated_base_url(value)
        uri = URI.parse(value.to_s)
        valid = uri.scheme == "https" && uri.host.present? && uri.userinfo.nil? && uri.query.nil? && uri.fragment.nil?
        raise ConfigurationError, "provider base URL must be fixed HTTPS" unless valid

        uri.to_s
      rescue URI::InvalidURIError
        raise ConfigurationError, "provider base URL must be fixed HTTPS"
      end

      def validate_path!(path)
        uri = URI.parse(path.to_s)
        valid = path.to_s.start_with?("/") && !path.to_s.start_with?("//") && uri.host.nil? && uri.scheme.nil?
        raise ConfigurationError, "provider request path must be relative" unless valid
      rescue URI::InvalidURIError
        raise ConfigurationError, "provider request path must be relative"
      end
  end
end
