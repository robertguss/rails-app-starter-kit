require "test_helper"

class JsonLogFormatterTest < ActiveSupport::TestCase
  test "emits parseable structured fields with correlation identifiers" do
    Current.request_id = "request-123"
    Current.job_id = "job-456"

    line = JsonLogFormatter.new.call("INFO", Time.utc(2026, 8, 24), nil, "ready")
    payload = JSON.parse(line)

    assert_equal "INFO", payload.fetch("severity")
    assert_equal "ready", payload.fetch("message")
    assert_equal "request-123", payload.fetch("request_id")
    assert_equal "job-456", payload.fetch("job_id")
  ensure
    Current.reset
  end
end
