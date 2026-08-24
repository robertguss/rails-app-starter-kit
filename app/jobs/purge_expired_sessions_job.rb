class PurgeExpiredSessionsJob < ApplicationJob
  queue_as :maintenance

  retry_on ActiveRecord::ConnectionNotEstablished, ActiveRecord::ConnectionTimeoutError,
    wait: :polynomially_longer, attempts: 5
  discard_on ActiveJob::DeserializationError

  def perform(cutoff = Time.current)
    Session.where(revoked_at: nil, expires_at: ..cutoff).update_all(revoked_at: cutoff, updated_at: cutoff)
  end
end
