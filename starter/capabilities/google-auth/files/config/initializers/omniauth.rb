# frozen_string_literal: true

OmniAuth.config.allowed_request_methods = %i[post]
OmniAuth.config.silence_get_warning = true

methods = ENV.fetch("AUTH_METHODS", "google").split(",").map(&:strip)
if methods.include?("google") && ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, ENV.fetch("GOOGLE_CLIENT_ID"), ENV.fetch("GOOGLE_CLIENT_SECRET"), hd: ENV.fetch("GOOGLE_WORKSPACE_DOMAINS", "").split(",").first
  end
end
