# frozen_string_literal: true

# Telemetry is entirely optional. Without an endpoint this capability allocates
# no exporter, opens no connection, and changes no application behavior.
if ENV["OTEL_EXPORTER_OTLP_ENDPOINT"].present?
  require "opentelemetry/exporter/otlp"
  require "opentelemetry/instrumentation/active_job"
  require "opentelemetry/instrumentation/active_record"
  require "opentelemetry/instrumentation/faraday"
  require "opentelemetry/instrumentation/rails"
  require "opentelemetry/sdk"

  OpenTelemetry::SDK.configure do |configuration|
    configuration.service_name = ENV.fetch("OTEL_SERVICE_NAME", Rails.application.class.module_parent_name.underscore)
    configuration.use "OpenTelemetry::Instrumentation::Rails"
    configuration.use "OpenTelemetry::Instrumentation::ActiveRecord"
    configuration.use "OpenTelemetry::Instrumentation::ActiveJob"
    configuration.use "OpenTelemetry::Instrumentation::Faraday"
  end
end
