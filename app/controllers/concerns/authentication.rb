module Authentication
  extend ActiveSupport::Concern

  METHODS = %w[google password].freeze

  included do
    before_action :resume_session
    helper_method :authenticated?
  end

  private
    def resume_session
      raw = cookies.encrypted[:session_token]
      Current.session = Session.includes(user: :access_grant).find_by(token_digest: TokenDigest.call(raw)) if raw.present?
      Current.session = nil unless Current.session&.live?
    end

    def require_authentication
      return if authenticated?
      redirect_to login_path(return_to: Authentication.internal_path(request.fullpath))
    end

    def authenticated? = Current.user.present?

    def start_session_for(user)
      Current.session&.update!(revoked_at: Time.current)
      record, raw = Session.issue!(user:, user_agent: request.user_agent, ip_address: request.remote_ip)
      adopt_session(record, raw)
    end

    def adopt_session(record, raw)
      cookies.encrypted[:session_token] = { value: raw, httponly: true, same_site: :lax, secure: Rails.env.production?, expires: record.expires_at }
      Current.session = record
    end

    def terminate_session
      Current.session&.update!(revoked_at: Time.current)
      cookies.delete(:session_token)
      Current.session = nil
    end

    def self.enabled_methods
      ENV.fetch("AUTH_METHODS", "password").split(",").map(&:strip).intersection(METHODS)
    end

    def self.method_enabled?(method)
      enabled_methods.include?(method.to_s)
    end

    def self.internal_path(value)
      path = value.to_s
      uri = URI.parse(path)
      internal = path.start_with?("/") && !path.start_with?("//") && !path.match?(/[\\\x00-\x1f]/) && uri.scheme.nil? && uri.host.nil?
      internal ? path : "/"
    rescue URI::InvalidURIError
      "/"
    end
end
