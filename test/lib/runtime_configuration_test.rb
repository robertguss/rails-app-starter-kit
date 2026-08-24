require "test_helper"

class RuntimeConfigurationTest < ActiveSupport::TestCase
  def production_environment
    {
      "ACTIVE_STORAGE_ROOT" => "/rails/storage",
      "APP_HOST" => "app.example.test",
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

  test "reports all missing S3 and SMTP settings without their values" do
    environment = production_environment.merge("MAIL_DELIVERY_METHOD" => "smtp", "STORAGE_SERVICE" => "s3")

    error = assert_raises(RuntimeConfiguration::Error) { RuntimeConfiguration.validate!(environment:) }

    %w[AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY S3_BUCKET S3_REGION SMTP_ADDRESS SMTP_DOMAIN SMTP_PORT].each do |name|
      assert_includes error.message, name
    end
    refute_includes error.message, "secret"
  end
end
