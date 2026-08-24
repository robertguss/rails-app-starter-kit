# frozen_string_literal: true

class AgentSessionsController < ApplicationController
  skip_before_action :require_authentication
  skip_forgery_protection

  SEEDED_USERS = {
    "owner" => "owner@example.test",
    "member" => "member@example.test",
    "second" => "second@example.test"
  }.freeze

  class_attribute :environment_guard, default: -> { Rails.env }
  def self.available?(environment = environment_guard.call)
    environment = environment.to_s
    environment == "development" || (environment != "production" && ENV["AGENT_LOGIN_ENABLED"] == "1")
  end

  def create
    return head :not_found unless self.class.available?
    email = SEEDED_USERS[params[:user].to_s]
    return head :not_found unless email

    user = User.find_by!(email_address: email, active: true)
    start_session_for(user)
    AuditEvent.record!(actor: user, action: "agent.session_created", subject: user)
    redirect_to Authentication.internal_path(params[:return_to])
  end
end
