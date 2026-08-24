# frozen_string_literal: true

class OperationItem < ApplicationRecord
  belongs_to :operation

  validates :external_key, presence: true, uniqueness: { scope: :operation_id }
  validates :status, inclusion: { in: %w[pending succeeded failed] }

  def succeed!(summary: {})
    update!(
      status: "succeeded",
      result_summary: summary,
      error_category: nil,
      error_message: nil,
      finished_at: Time.current
    )
  end

  def fail!(category:, message:)
    update!(
      status: "failed",
      error_category: category.to_s,
      error_message: sanitized(message),
      finished_at: Time.current
    )
  end

  private
    def sanitized(message)
      message.to_s.truncate(500).gsub(/(bearer|token|secret|password|key)[=: ]+\S+/i, "\\1=[FILTERED]")
    end
end
