# frozen_string_literal: true

class CreateOperationItems < ActiveRecord::Migration[8.1]
  def change
    create_table :operation_items do |t|
      t.references :operation, null: false, foreign_key: { on_delete: :cascade }
      t.string :external_key, null: false
      t.string :status, null: false, default: "pending"
      t.jsonb :input_summary, null: false, default: {}
      t.jsonb :result_summary, null: false, default: {}
      t.string :error_category
      t.string :error_message
      t.datetime :finished_at
      t.timestamps
    end
    add_index :operation_items, %i[operation_id external_key], unique: true
    add_check_constraint :operation_items,
      "status IN ('pending','succeeded','failed')", name: "operation_items_status"
    add_check_constraint :operation_items,
      "(status = 'pending') = (finished_at IS NULL)", name: "operation_items_terminal_time"
  end
end
