require "json"
require "logger"
require "time"

class JsonLogFormatter < Logger::Formatter
  def call(severity, timestamp, program_name, message)
    payload = {
      timestamp: timestamp.utc.iso8601(6),
      severity: severity,
      message: message.is_a?(String) ? message : message.inspect
    }

    payload[:program] = program_name if program_name
    payload[:request_id] = Current.request_id if defined?(Current) && Current.request_id
    payload[:job_id] = Current.job_id if defined?(Current) && Current.job_id
    payload[:operation_id] = Current.operation_id if defined?(Current) && Current.operation_id

    "#{JSON.generate(payload)}\n"
  end
end
