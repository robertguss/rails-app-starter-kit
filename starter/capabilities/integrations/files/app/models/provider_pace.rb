# frozen_string_literal: true

class ProviderPace < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :next_available_at, presence: true

  def self.reserve!(key:, interval:, now: Time.current)
    transaction(requires_new: true) do
      pace = lock.find_or_create_by!(key:) { |record| record.next_available_at = now }
      ready_at = [ pace.next_available_at, now ].max
      pace.update!(next_available_at: ready_at + interval)
      [ ready_at - now, 0 ].max
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
