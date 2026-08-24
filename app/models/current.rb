class Current < ActiveSupport::CurrentAttributes
  attribute :job_id, :request_id, :session
  delegate :user, to: :session, allow_nil: true
end
