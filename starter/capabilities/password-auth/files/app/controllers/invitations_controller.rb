# frozen_string_literal: true

class InvitationsController < ApplicationController
  skip_before_action :require_authentication
  before_action :require_password_authentication

  def show = render inertia: "auth/invitation", props: { token: params[:token] }

  def update
    _user, session, raw_session_token = InvitationAcceptance.call!(
      token: params[:token],
      name: params[:name],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )
    adopt_session(session, raw_session_token)
    redirect_to root_path, notice: "Your account is ready."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to invitation_path(params[:token]), inertia: { errors: error.record.errors }
  rescue ActiveRecord::RecordNotFound
    redirect_to login_path, alert: "This invitation is invalid or expired."
  end

  private
    def require_password_authentication
      head :not_found unless Authentication.method_enabled?(:password)
    end
end
