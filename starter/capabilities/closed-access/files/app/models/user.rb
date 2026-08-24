# frozen_string_literal: true

class User < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_one :access_grant, foreign_key: :claimed_by_id, inverse_of: :claimed_by, dependent: :restrict_with_error

  normalizes :email_address, with: ->(email) { email.strip.downcase }
  enum :role, { member: "member", owner: "owner" }, validate: true
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  attr_readonly :email_address
  before_update :prevent_owner_removal
  before_destroy :prevent_owner_destruction

  def access_active?
    active? && access_grant&.active?
  end

  private
    def prevent_owner_removal
      return unless role_was == "owner" && (role_changed? || active_changed? && !active?)

      errors.add(:base, "transfer ownership before changing the owner")
      throw :abort
    end

    def prevent_owner_destruction
      return unless owner?

      errors.add(:base, "transfer ownership before deleting the owner")
      throw :abort
    end
end
