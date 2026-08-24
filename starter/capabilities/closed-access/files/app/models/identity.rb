# frozen_string_literal: true

class Identity < ApplicationRecord
  belongs_to :user
  validates :provider, :provider_subject, :provider_email, presence: true
  validates :provider_subject, uniqueness: { scope: :provider }
  attr_readonly :provider, :provider_subject
end
