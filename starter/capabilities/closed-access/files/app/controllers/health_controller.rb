# frozen_string_literal: true

class HealthController < ApplicationController
  skip_before_action :require_authentication

  def show
    database_connected = ActiveRecord::Base.connection.select_value("SELECT 1") == 1

    render inertia: "health/show", props: {
      status: database_connected ? "ok" : "degraded",
      checks: {
        application: "ok",
        database: database_connected ? "ok" : "unavailable"
      }
    }, status: database_connected ? :ok : :service_unavailable
  rescue ActiveRecord::ActiveRecordError
    render inertia: "health/show", props: {
      status: "degraded",
      checks: { application: "ok", database: "unavailable" }
    }, status: :service_unavailable
  end
end
