class PasswordRecoveriesController < ApplicationController
  skip_before_action :require_authentication
  rate_limit to: 5, within: 15.minutes, only: :create
  before_action :require_password_authentication

  def new = render inertia: "auth/recovery_request"

  def create
    PasswordRecoveryService.request(params[:email_address])
    redirect_to login_path, notice: "If that account exists, recovery instructions have been sent."
  end
  def edit = render inertia: "auth/recovery_reset", props: { token: params[:token] }
  def update
    PasswordRecoveryService.reset!(
      token: params[:token],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
    redirect_to login_path, notice: "Password changed. Sign in again."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to edit_password_recovery_path(params[:token]), inertia: { errors: error.record.errors }
  rescue ActiveRecord::RecordNotFound
    redirect_to new_password_recovery_path, alert: "This recovery link is invalid or expired."
  end

  private
    def require_password_authentication
      head :not_found unless Authentication.method_enabled?(:password)
    end
end
