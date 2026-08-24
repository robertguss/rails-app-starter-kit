# frozen_string_literal: true

class AccessGrant < ApplicationRecord
  belongs_to :granted_by, class_name: "User", optional: true
  belongs_to :revoked_by, class_name: "User", optional: true
  belongs_to :claimed_by, class_name: "User", optional: true
  has_many :invitations, dependent: :destroy
  normalizes :normalized_email, with: ->(email) { email.strip.downcase }
  validates :normalized_email, presence: true, uniqueness: true
  validate :claim_cannot_be_reassigned, on: :update
  attr_readonly :normalized_email
  before_destroy :prevent_owner_destruction

  def revoke!(actor:)
    with_lock do
      if claimed_by&.owner?
        errors.add(:base, "transfer ownership before revoking the owner")
        raise ActiveRecord::RecordInvalid, self
      end

      update!(active: false, revoked_by: actor, revoked_at: Time.current)
      invitations.where(revoked_at: nil).update_all(revoked_at: Time.current)
      claimed_by&.sessions&.live&.update_all(revoked_at: Time.current)
      AuditEvent.record!(actor:, action: "access.revoked", subject: self)
    end
  end

  private
    def claim_cannot_be_reassigned
      changed = claimed_by_id_was.present? && will_save_change_to_claimed_by_id?
      changed ||= claimed_at_was.present? && will_save_change_to_claimed_at?
      errors.add(:claimed_by, "cannot be reassigned") if changed
    end

    def prevent_owner_destruction
      return unless claimed_by&.owner?

      errors.add(:base, "transfer ownership before deleting the owner's grant")
      throw :abort
    end
end
