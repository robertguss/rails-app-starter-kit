require "test_helper"

class RuntimeConfigurationTest < ActiveSupport::TestCase
  def production_environment
    {
      "ACTIVE_STORAGE_ROOT" => "/rails/storage",
      "APP_HOST" => "app.example.test",
      "AUTH_METHODS" => "password",
      "DATABASE_URL" => "postgresql://starter:secret@postgres/starter_production",
      "FORCE_SSL" => "true",
      "MAIL_DELIVERY_METHOD" => "none",
      "RAILS_ENV" => "production",
      "SECRET_KEY_BASE" => "s" * 64,
      "STORAGE_SERVICE" => "local"
    }
  end

  test "accepts the complete password and local storage configuration" do
    assert RuntimeConfiguration.validate!(environment: production_environment)
  end

  test "rejects any authentication method other than password" do
    assert_equal [ "AUTH_METHODS" ], RuntimeConfiguration.invalid_names(environment: production_environment.merge("AUTH_METHODS" => "unknown"))
  end
end
