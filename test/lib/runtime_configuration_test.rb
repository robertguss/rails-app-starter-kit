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

  test "accepts the complete local storage configuration" do
    assert RuntimeConfiguration.validate!(environment: production_environment)
  end

  test "reports all missing S3 SMTP and Google settings without their values" do
    environment = production_environment.merge(
      "AUTH_METHODS" => "google",
      "MAIL_DELIVERY_METHOD" => "smtp",
      "STORAGE_SERVICE" => "s3"
    )

    error = assert_raises(RuntimeConfiguration::Error) do
      RuntimeConfiguration.validate!(environment:)
    end

    %w[
      AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET
      GOOGLE_WORKSPACE_DOMAINS S3_BUCKET S3_REGION SMTP_ADDRESS SMTP_DOMAIN SMTP_PORT
    ].each { |name| assert_includes error.message, name }
    refute_includes error.message, "secret"
  end

  test "rejects invalid production primitives" do
    environment = production_environment.merge(
      "APP_HOST" => "https://app.example.test/path",
      "AUTH_METHODS" => "unknown",
      "DATABASE_URL" => "sqlite3:tmp/db",
      "FORCE_SSL" => "sometimes",
      "MAIL_DELIVERY_METHOD" => "sendmail",
      "SECRET_KEY_BASE" => "short",
      "STORAGE_SERVICE" => "unknown"
    )

    assert_equal %w[APP_HOST AUTH_METHODS DATABASE_URL FORCE_SSL MAIL_DELIVERY_METHOD SECRET_KEY_BASE STORAGE_SERVICE],
      RuntimeConfiguration.invalid_names(environment:)
  end
end
