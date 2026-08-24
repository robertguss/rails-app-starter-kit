class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create

  def new
    render inertia: "auth/login", props: {
      csrf_token: form_authenticity_token,
      return_to: Authentication.internal_path(params[:return_to]),
      methods: Authentication.enabled_methods
    }
  end

  def create
    return head :not_found unless Authentication.method_enabled?(:password)

    user = User.authenticate_by(email_address: params[:email_address].to_s.strip.downcase, password: params[:password])
    if user&.access_active?
      start_session_for(user)
      AuditEvent.record!(actor: user, action: "session.created", subject: user)
      redirect_to Authentication.internal_path(params[:return_to])
    else
      redirect_to login_path, alert: "Email or password is incorrect."
    end
  end

  def destroy
    AuditEvent.record!(actor: Current.user, action: "session.destroyed", subject: Current.session) if Current.session
    terminate_session
    redirect_to login_path
  end
end
