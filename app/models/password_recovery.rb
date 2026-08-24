class PasswordRecovery < ApplicationRecord
  belongs_to :user
  validates :token_digest, :expires_at, presence: true
  validates :token_digest, uniqueness: true
  validate :terminal_state_cannot_be_reopened, on: :update
  attr_readonly :user_id, :token_digest, :expires_at

  scope :live, -> { where(consumed_at: nil, revoked_at: nil).where(expires_at: Time.current..) }

  private
    def terminal_state_cannot_be_reopened
      changed = consumed_at_was.present? && will_save_change_to_consumed_at?
      changed ||= revoked_at_was.present? && will_save_change_to_revoked_at?
      errors.add(:base, "a terminal token state cannot be changed") if changed
    end
end
