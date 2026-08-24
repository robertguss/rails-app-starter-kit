class ReadinessController < ActionController::Base
  def show
    database_ready = ActiveRecord::Base.connection.select_value("SELECT 1") == 1 &&
      !ActiveRecord::Base.connection_pool.migration_context.needs_migration?

    render json: {
      status: database_ready ? "ready" : "not_ready",
      checks: { database: database_ready ? "ready" : "not_ready" }
    }, status: database_ready ? :ok : :service_unavailable
  rescue ActiveRecord::ActiveRecordError
    render json: {
      status: "not_ready",
      checks: { database: "unavailable" }
    }, status: :service_unavailable
  end
end
