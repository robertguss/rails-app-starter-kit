# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  before_action :require_authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  inertia_share flash: -> { { notice: flash[:notice], alert: flash[:alert] }.compact }, auth: -> { { user: Current.user&.slice(:id, :name, :email_address, :role) } }
end
