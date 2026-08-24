class ErrorsController < ApplicationController
  skip_before_action :require_authentication

  def not_found
    render inertia: "errors/not_found", status: :not_found
  end

  def internal_server_error
    render inertia: "errors/internal_server_error", status: :internal_server_error
  end
end
