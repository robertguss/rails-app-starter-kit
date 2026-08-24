require "test_helper"

class ApplicationConfigurationTest < ActiveSupport::TestCase
  test "production SSR remains disabled" do
    assert_equal false, InertiaRails.configuration.ssr_enabled
    assert_empty Dir[Rails.root.join("app/frontend/entrypoints/*ssr*")]

    package = JSON.parse(Rails.root.join("package.json").read)
    assert_nil package.fetch("scripts")["ssr"]
  end
end
