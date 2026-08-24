require_relative "boot"
require_relative "../lib/json_log_formatter"
require_relative "../lib/request_context"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsAppStarterKit
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])
    config.exceptions_app = routes
    config.middleware.insert_after ActionDispatch::RequestId, RequestContext

    # File workflows and image processing are configured in Phase 4.
    config.active_storage.variant_processor = :disabled

    config.generators do |generators|
      generators.assets = false
      generators.helper = false
      generators.system_tests = nil
    end
  end
end
