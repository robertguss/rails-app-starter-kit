class ApplicationJob < ActiveJob::Base
  around_perform do |job, block|
    Current.job_id = job.job_id
    Current.request_id = job.correlation_id
    block.call
  ensure
    Current.reset
  end

  attr_reader :correlation_id

  def serialize
    super.merge("correlation_id" => Current.request_id)
  end

  def deserialize(job_data)
    super
    @correlation_id = job_data["correlation_id"]
  end
end
