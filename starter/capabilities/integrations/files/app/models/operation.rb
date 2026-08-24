# frozen_string_literal: true

class Operation < ApplicationRecord
  TERMINAL_STATUSES = %w[succeeded partially_succeeded failed].freeze
  STATUSES = (%w[pending running] + TERMINAL_STATUSES).freeze
  STALE_AFTER = 5.minutes

  belongs_to :actor, class_name: "User"
  has_many :items, class_name: "OperationItem", dependent: :destroy

  validates :kind, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :idempotency_key, presence: true, allow_nil: true
  validates :progress_current, :progress_total, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :progress_is_bounded

  scope :stale, ->(before: STALE_AFTER.ago) { where(status: "running").where("heartbeat_at < ?", before) }

  def self.create_idempotent!(actor:, kind:, idempotency_key:, request_summary: {})
    key = idempotency_key.to_s.strip.presence
    return [ create!(actor:, kind:, request_summary:), true ] unless key

    existing = find_by(kind:, idempotency_key: key)
    return existing_result(existing, actor) if existing

    [ create!(actor:, kind:, idempotency_key: key, request_summary:), true ]
  rescue ActiveRecord::RecordNotUnique
    existing_result(find_by!(kind:, idempotency_key: key), actor)
  end

  def claim!(worker_id:, now: Time.current, stale_after: STALE_AFTER)
    with_lock do
      return false if terminal?
      return false if status == "running" && claimed_by != worker_id && heartbeat_at && heartbeat_at >= now - stale_after

      update!(
        status: "running",
        claimed_by: worker_id,
        claimed_at: now,
        heartbeat_at: now,
        started_at: started_at || now,
        error_category: nil,
        error_message: nil
      )
      true
    end
  end

  def record_progress!(current:, total:, step:, worker_id:, now: Time.current)
    with_lock do
      raise ActiveRecord::StaleObjectError, self unless status == "running" && claimed_by == worker_id

      update!(progress_current: current, progress_total: total, current_step: step, heartbeat_at: now)
    end
  end

  def finish!(status:, result_summary:, worker_id:, now: Time.current)
    raise ArgumentError, "not a successful terminal status" unless %w[succeeded partially_succeeded].include?(status)

    with_lock do
      raise ActiveRecord::StaleObjectError, self unless self.status == "running" && claimed_by == worker_id

      update!(status:, result_summary:, current_step: "complete", heartbeat_at: now, finished_at: now)
    end
  end

  def fail!(category:, message:, now: Time.current)
    with_lock do
      return if terminal?

      update!(
        status: "failed",
        error_category: category.to_s,
        error_message: sanitized(message),
        heartbeat_at: now,
        finished_at: now
      )
    end
  end

  def terminal? = TERMINAL_STATUSES.include?(status)

  def stale?(now: Time.current, stale_after: STALE_AFTER)
    status == "running" && heartbeat_at.present? && heartbeat_at < now - stale_after
  end

  def status_payload
    {
      id:,
      kind:,
      status:,
      current_step:,
      progress_current:,
      progress_total:,
      result_summary:,
      error_category:,
      error_message:,
      started_at:,
      finished_at:
    }
  end

  def self.existing_result(existing, actor)
    raise Integrations::Conflict, "idempotency key belongs to another actor" unless existing.actor_id == actor.id

    [ existing, false ]
  end
  private_class_method :existing_result

  private
    def sanitized(message)
      message.to_s.truncate(500).gsub(/(bearer|token|secret|password|key)[=: ]+\S+/i, "\\1=[FILTERED]")
    end

    def progress_is_bounded
      return if progress_total.zero? || progress_current <= progress_total

      errors.add(:progress_current, "cannot exceed total")
    end
end
