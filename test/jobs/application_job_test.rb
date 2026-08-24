require "test_helper"

class ApplicationJobTest < ActiveJob::TestCase
  class CorrelatedJob < ApplicationJob
    def perform
      Current.request_id
    end
  end

  test "serializes the request correlation identifier" do
    Current.request_id = "request-123"

    serialized = CorrelatedJob.new.serialize

    assert_equal "request-123", serialized.fetch("correlation_id")
  ensure
    Current.reset
  end
end
