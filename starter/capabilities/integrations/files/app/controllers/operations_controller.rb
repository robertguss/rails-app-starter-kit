# frozen_string_literal: true

class OperationsController < ApplicationController
  ALLOWED_SIMULATIONS = %w[success timeout rate_limited authentication_failure invalid_response partial_success ambiguous_write interruption].freeze

  before_action :require_owner

  def index
    render inertia: "operations/index", props: {
      operations: Operation.includes(:actor).order(created_at: :desc).limit(50).map { |operation| operation_props(operation) },
      simulations: Rails.env.production? ? [] : ALLOWED_SIMULATIONS
    }
  end

  def show
    operation = Operation.includes(:items, :actor).find(params[:id])
    render inertia: "operations/show", props: {
      operation: operation_props(operation),
      items: operation.items.order(:id).map { |item| item_props(item) }
    }
  end

  def status
    operation = Operation.includes(:items, :actor).find(params[:id])
    render json: {
      operation: operation_props(operation),
      items: operation.items.order(:id).map { |item| item_props(item) }
    }
  end

  def create
    operation, created = Operation.create_idempotent!(
      actor: Current.user,
      kind: "fixture_import",
      idempotency_key: params[:idempotency_key],
      request_summary: { simulation: normalized_simulation }
    )
    if created
      AuditEvent.record!(actor: Current.user, action: "operation.started", subject: operation, metadata: { kind: operation.kind })
      FixtureImportJob.perform_later(operation.id)
    end
    redirect_to operation_path(operation)
  end

  private
    def require_owner
      head :forbidden unless Current.user&.owner?
    end

    def normalized_simulation
      simulation = params.fetch(:simulation, "success").to_s
      return "success" if Rails.env.production?
      return simulation if ALLOWED_SIMULATIONS.include?(simulation)

      raise ActionController::BadRequest, "unknown fixture simulation"
    end

    def operation_props(operation)
      operation.status_payload.merge(
        actor: operation.actor.name,
        created_at: operation.created_at.iso8601
      )
    end

    def item_props(item)
      {
        id: item.id,
        external_key: item.external_key,
        status: item.status,
        input_summary: item.input_summary,
        result_summary: item.result_summary,
        error_category: item.error_category,
        error_message: item.error_message
      }
    end
end
