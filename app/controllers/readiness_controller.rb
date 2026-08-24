class ReadinessController < ActionController::Base
  def show
    database_connected = ActiveRecord::Base.connection.select_value("SELECT 1") == 1
    migrations_current = !ActiveRecord::Base.connection_pool.migration_context.needs_migration?
    queue_ready = ActiveRecord::Base.connection.data_source_exists?("solid_queue_jobs")
    ready = database_connected && migrations_current && queue_ready

    render json: {
      status: ready ? "ready" : "not_ready",
      checks: {
        database: database_connected ? "ready" : "not_ready",
        migrations: migrations_current ? "ready" : "not_ready",
        queue: queue_ready ? "ready" : "not_ready"
      }
    }, status: ready ? :ok : :service_unavailable
  rescue ActiveRecord::ActiveRecordError
    render json: {
      status: "not_ready",
      checks: { database: "unavailable", migrations: "unknown", queue: "unknown" }
    }, status: :service_unavailable
  end
end
