class User < ApplicationRecord
  attr_accessor :passwordless

  has_secure_password validations: false
  has_many :sessions, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_many :password_recoveries, dependent: :destroy
  has_one :access_grant, foreign_key: :claimed_by_id, inverse_of: :claimed_by, dependent: :restrict_with_error

  normalizes :email_address, with: ->(email) { email.strip.downcase }
  enum :role, { member: "member", owner: "owner" }, validate: true
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :password, length: { minimum: 12 }, allow_nil: true
  validates :password, confirmation: { case_sensitive: true }, if: -> { password.present? }
  attr_readonly :email_address
  validate :password_required_for_password_account, on: :create
  before_update :prevent_owner_removal
  before_destroy :prevent_owner_destruction

  def access_active?
    active? && access_grant&.active?
  end

  private
    def password_required_for_password_account
      errors.add(:password, "is required") if password_digest.blank? && !passwordless
    end

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
