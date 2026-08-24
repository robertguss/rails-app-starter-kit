class OmniauthCallbacksController < ApplicationController
  skip_before_action :require_authentication
  before_action :require_google_authentication

  def google
    _user, session, raw_session_token = GoogleAuthenticator.call!(
      request.env.fetch("omniauth.auth"),
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )
    adopt_session(session, raw_session_token)
    redirect_to Authentication.internal_path(request.env["omniauth.origin"])
  rescue GoogleAuthenticator::Denied, KeyError
    AuditEvent.record!(action: "google.denied")
    redirect_to login_path, alert: "Google access was not authorized."
  end

  def failure = redirect_to(login_path, alert: "Google access was not authorized.")

  private
    def require_google_authentication
      head :not_found unless Authentication.method_enabled?(:google)
    end
end
