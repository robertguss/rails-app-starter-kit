# frozen_string_literal: true

class Session < ApplicationRecord
  LIFETIME = 30.days
  belongs_to :user
  validates :token_digest, :expires_at, presence: true
  validates :token_digest, uniqueness: true
  validate :revocation_cannot_be_reopened, on: :update
  attr_readonly :user_id, :token_digest, :expires_at

  scope :live, -> { where(revoked_at: nil).where(expires_at: Time.current..) }

  def self.issue!(user:, user_agent: nil, ip_address: nil)
    raw = SecureRandom.urlsafe_base64(32)
    record = create!(user:, token_digest: TokenDigest.call(raw), user_agent:, ip_address:, expires_at: LIFETIME.from_now)
    [ record, raw ]
  end

  def live? = revoked_at.nil? && expires_at.future? && User.joins(:access_grant).where(id: user_id, active: true, access_grants: { active: true }).exists?

  private
    def revocation_cannot_be_reopened
      errors.add(:revoked_at, "cannot be changed after revocation") if revoked_at_was.present? && will_save_change_to_revoked_at?
    end
end
