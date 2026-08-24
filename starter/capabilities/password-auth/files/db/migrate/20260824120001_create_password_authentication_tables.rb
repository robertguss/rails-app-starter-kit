# frozen_string_literal: true

class CreatePasswordAuthenticationTables < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :password_digest, :string
    create_token_table :invitations, parent: :access_grant
    create_token_table :password_recoveries, parent: :user
  end

  private
    def create_token_table(name, parent:)
      create_table name do |t|
        t.references parent, null: false, foreign_key: { on_delete: :cascade }
        t.string :token_digest, null: false
        t.datetime :expires_at, null: false
        t.datetime :consumed_at
        t.datetime :revoked_at
        t.timestamps
      end
      add_index name, :token_digest, unique: true
      add_check_constraint name, "expires_at > created_at", name: "#{name}_positive_lifetime"
      add_check_constraint name,
        "(consumed_at IS NULL OR consumed_at >= created_at) AND (revoked_at IS NULL OR revoked_at >= created_at)",
        name: "#{name}_valid_terminal_time"
      add_check_constraint name,
        "NOT (consumed_at IS NOT NULL AND revoked_at IS NOT NULL)",
        name: "#{name}_single_terminal_state"
    end
end
