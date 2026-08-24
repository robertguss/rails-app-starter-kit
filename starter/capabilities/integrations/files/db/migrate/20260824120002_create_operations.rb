# frozen_string_literal: true

class CreateOperations < ActiveRecord::Migration[8.1]
  def change
    create_table :operations do |t|
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :kind, null: false
      t.string :status, null: false, default: "pending"
      t.string :idempotency_key
      t.string :current_step
      t.integer :progress_current, null: false, default: 0
      t.integer :progress_total, null: false, default: 0
      t.jsonb :request_summary, null: false, default: {}
      t.jsonb :result_summary, null: false, default: {}
      t.string :error_category
      t.string :error_message
      t.string :claimed_by
      t.datetime :claimed_at
      t.datetime :heartbeat_at
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end
    add_index :operations, %i[kind idempotency_key], unique: true,
      where: "idempotency_key IS NOT NULL", name: "index_operations_on_kind_and_idempotency"
    add_index :operations, %i[status heartbeat_at]
    add_check_constraint :operations,
      "status IN ('pending','running','succeeded','partially_succeeded','failed')",
      name: "operations_status"
    add_check_constraint :operations, "progress_current >= 0", name: "operations_progress_current"
    add_check_constraint :operations, "progress_total >= 0", name: "operations_progress_total"
    add_check_constraint :operations,
      "progress_total = 0 OR progress_current <= progress_total",
      name: "operations_progress_bounds"
    add_check_constraint :operations,
      "(status IN ('succeeded','partially_succeeded','failed')) = (finished_at IS NOT NULL)",
      name: "operations_terminal_time"

    create_table :provider_paces do |t|
      t.string :key, null: false
      t.datetime :next_available_at, null: false
      t.timestamps
    end
    add_index :provider_paces, :key, unique: true
  end
end
