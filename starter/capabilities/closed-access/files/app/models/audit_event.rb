# frozen_string_literal: true

class AuditEvent < ApplicationRecord
  belongs_to :actor, class_name: "User", optional: true
  validates :action, :occurred_at, presence: true
  attr_readonly :actor_id, :action, :subject_type, :subject_id, :metadata, :occurred_at
  before_update :raise_read_only
  before_destroy :raise_read_only

  def self.record!(actor: nil, action:, subject: nil, metadata: {})
    create!(actor:, action:, subject_type: subject&.class&.name, subject_id: subject&.id, metadata:, occurred_at: Time.current)
  end

  private
    def raise_read_only
      raise ActiveRecord::ReadOnlyRecord, "audit events are append-only"
    end
end
