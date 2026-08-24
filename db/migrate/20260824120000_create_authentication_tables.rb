class CreateAuthenticationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :name, null: false
      t.string :password_digest
      t.boolean :active, null: false, default: true
      t.string :role, null: false, default: "member"
      t.timestamps
    end
    add_index :users, "lower(email_address)", unique: true
    add_index :users, :role, unique: true, where: "role = 'owner'", name: "index_users_one_owner"
    add_check_constraint :users, "role IN ('owner','member')", name: "users_role"

    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :token_digest, null: false
      t.string :user_agent
      t.inet :ip_address
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end
    add_index :sessions, :token_digest, unique: true
    add_check_constraint :sessions, "expires_at > created_at", name: "sessions_positive_lifetime"
    add_check_constraint :sessions, "revoked_at IS NULL OR revoked_at >= created_at", name: "sessions_valid_revocation"

    create_table :identities do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :provider, null: false
      t.string :provider_subject, null: false
      t.string :provider_email, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :identities, %i[provider provider_subject], unique: true

    create_table :access_grants do |t|
      t.string :normalized_email, null: false
      t.boolean :active, null: false, default: true
      t.references :granted_by, foreign_key: { to_table: :users }
      t.datetime :granted_at, null: false
      t.references :revoked_by, foreign_key: { to_table: :users }
      t.datetime :revoked_at
      t.references :claimed_by, foreign_key: { to_table: :users }, index: false
      t.datetime :claimed_at
      t.timestamps
    end
    add_index :access_grants, :normalized_email, unique: true
    add_index :access_grants, :claimed_by_id, unique: true, where: "claimed_by_id IS NOT NULL"
    add_check_constraint :access_grants,
      "(active AND revoked_at IS NULL) OR (NOT active AND revoked_at IS NOT NULL)",
      name: "access_grants_active_revocation"
    add_check_constraint :access_grants,
      "(claimed_by_id IS NULL AND claimed_at IS NULL) OR (claimed_by_id IS NOT NULL AND claimed_at IS NOT NULL)",
      name: "access_grants_claim"

    create_token_table :invitations, parent: :access_grant
    create_token_table :password_recoveries, parent: :user

    create_table :audit_events do |t|
      t.references :actor, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :subject_type
      t.bigint :subject_id
      t.jsonb :metadata, null: false, default: {}
      t.datetime :occurred_at, null: false
      t.timestamps
    end
    add_index :audit_events, %i[subject_type subject_id]
    add_check_constraint :audit_events,
      "(subject_type IS NULL AND subject_id IS NULL) OR (subject_type IS NOT NULL AND subject_id IS NOT NULL)",
      name: "audit_events_subject"

    reversible do |direction|
      direction.up do
        execute <<~SQL
          CREATE FUNCTION enforce_exactly_one_owner() RETURNS trigger AS $$
          BEGIN
            IF EXISTS (SELECT 1 FROM users) AND (
              SELECT count(*)
              FROM users
              INNER JOIN access_grants ON access_grants.claimed_by_id = users.id
              WHERE users.role = 'owner'
                AND users.active
                AND access_grants.active
                AND access_grants.revoked_at IS NULL
            ) <> 1 THEN
              RAISE EXCEPTION 'An application with users must have exactly one active owner with an active access grant';
            END IF;
            RETURN NULL;
          END;
          $$ LANGUAGE plpgsql;
        SQL
        execute <<~SQL
          CREATE CONSTRAINT TRIGGER users_exactly_one_owner
          AFTER INSERT OR UPDATE OR DELETE ON users
          DEFERRABLE INITIALLY DEFERRED
          FOR EACH ROW EXECUTE FUNCTION enforce_exactly_one_owner()
        SQL
        execute <<~SQL
          CREATE CONSTRAINT TRIGGER access_grants_exactly_one_owner
          AFTER INSERT OR UPDATE OR DELETE ON access_grants
          DEFERRABLE INITIALLY DEFERRED
          FOR EACH ROW EXECUTE FUNCTION enforce_exactly_one_owner()
        SQL
        execute <<~SQL
          CREATE FUNCTION prevent_audit_event_update() RETURNS trigger AS $$
          BEGIN
            RAISE EXCEPTION 'Audit events are append-only';
          END;
          $$ LANGUAGE plpgsql;
        SQL
        execute <<~SQL
          CREATE TRIGGER audit_events_append_only
          BEFORE UPDATE ON audit_events
          FOR EACH ROW EXECUTE FUNCTION prevent_audit_event_update()
        SQL
      end

      direction.down do
        execute "DROP TRIGGER IF EXISTS audit_events_append_only ON audit_events"
        execute "DROP FUNCTION IF EXISTS prevent_audit_event_update"
        execute "DROP TRIGGER IF EXISTS access_grants_exactly_one_owner ON access_grants"
        execute "DROP TRIGGER IF EXISTS users_exactly_one_owner ON users"
        execute "DROP FUNCTION IF EXISTS enforce_exactly_one_owner"
      end
    end
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
