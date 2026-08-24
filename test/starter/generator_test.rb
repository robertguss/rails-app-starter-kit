require "test_helper"
require "starter/generator"
require "tmpdir"

class StarterGeneratorTest < ActiveSupport::TestCase
  setup do
    @generator = Starter::Generator.new(root: Rails.root)
    @temporary_root = Pathname(Dir.mktmpdir("starter-generator"))
  end

  teardown do
    FileUtils.rm_rf(@temporary_root)
  end

  test "minimal is a clean independent foundation without authentication" do
    destination = generate("minimal")

    assert_equal "minimal", receipt(destination).fetch("profile")
    assert_path destination, "app/controllers/application_controller.rb"
    refute_path destination, "app/models/user.rb"
    refute_path destination, "app/controllers/sessions_controller.rb"
    refute_path destination, "starter"
    refute_path destination, "bin/new"
    refute_path destination, "docs/implementation-plan.md"
    assert_deployment_identity(destination, auth: "none")
    assert_clean_of_institutional_code(destination)
  end

  test "personal installs only the password closed-access capability" do
    destination = generate("personal")

    assert_equal %w[closed-access password-auth jobs storage email], receipt(destination).fetch("features")
    assert_path destination, "app/models/user.rb"
    assert_path destination, "app/controllers/password_recoveries_controller.rb"
    refute_path destination, "app/controllers/omniauth_callbacks_controller.rb"
    refute_path destination, "app/controllers/uploads_controller.rb"
    assert_deployment_identity(destination, auth: "password")
    assert_clean_of_institutional_code(destination)
  end

  test "internal installs workspace closed access without any institutional client" do
    destination = generate("internal")

    assert_path destination, "app/services/google_authenticator.rb"
    refute_path destination, "app/controllers/password_recoveries_controller.rb"
    refute_path destination, "app/controllers/uploads_controller.rb"
    assert_equal "google", destination.join(".env.example").read[/^AUTH_METHODS=(.*)$/, 1]
    assert_deployment_identity(destination, auth: "google")
    assert_clean_of_institutional_clients(destination)
  end

  test "unsupported combinations fail before creating a destination" do
    destination = @temporary_root.join("unsupported")

    error = assert_raises(Starter::Error) do
      @generator.generate(name: "unsupported", profile: "minimal", destination:, auth: "password", lock: false)
    end

    assert_includes error.message, "requires --auth none"
    refute destination.exist?
  end

  test "upload recipe is additive idempotent and reports its exact files" do
    destination = generate("personal")

    changed = @generator.apply_recipe("upload-workflow", destination:)

    assert_equal [
      ".starter.yml",
      "app/controllers/uploads_controller.rb",
      "app/models/user.rb",
      "config/routes.rb",
      "test/fixtures/files/example.txt",
      "test/integration/uploads_flow_test.rb"
    ], changed
    assert_includes destination.join("config/routes.rb").read, "resources :uploads"
    assert_includes destination.join("app/models/user.rb").read, "has_many_attached :uploads"
    assert_equal [], @generator.apply_recipe("upload-workflow", destination:)

    minimal = generate("minimal")
    assert_raises(Starter::Error) { @generator.apply_recipe("upload-workflow", destination: minimal) }
    refute_path minimal, "app/controllers/uploads_controller.rb"
  end

  private
    def generate(profile)
      destination = @temporary_root.join(profile)
      @generator.generate(name: "#{profile}-fixture", profile:, destination:, lock: false)
    end

    def receipt(destination)
      YAML.safe_load(destination.join(".starter.yml").read)
    end

    def assert_path(destination, relative)
      assert destination.join(relative).exist?, "expected #{relative} to exist"
    end

    def assert_deployment_identity(destination, auth:)
      application = receipt(destination).fetch("application")
      compose = destination.join("compose.yaml").read
      compose_environment = destination.join("compose.env.example").read
      environment = destination.join(".env.example").read
      render = destination.join("render.yaml").read
      services = destination.join(".amp/services.yaml").read

      assert_includes compose, "name: #{application}"
      assert_includes compose, "image: #{application}:local"
      assert_includes compose, "AUTH_METHODS: ${AUTH_METHODS:-#{auth}}"
      assert_includes compose, "#{application.tr('-', '_')}_production"
      assert_includes compose_environment, "AUTH_METHODS=#{auth}"
      assert_includes environment, "AUTH_METHODS=#{auth}"
      assert_includes render, "name: #{application}-web"
      assert_includes services, "title: #{application.split('-').map(&:capitalize).join(' ')}"
      if auth == "google"
        assert_includes environment, "GOOGLE_WORKSPACE_DOMAINS=example.com"
        assert_includes environment, "GOOGLE_CLIENT_ID="
        assert_includes environment, "GOOGLE_CLIENT_SECRET="
        assert_includes compose, "GOOGLE_CLIENT_ID: ${GOOGLE_CLIENT_ID:?set GOOGLE_CLIENT_ID}"
        assert_includes compose, "GOOGLE_CLIENT_SECRET: ${GOOGLE_CLIENT_SECRET:?set GOOGLE_CLIENT_SECRET}"
        assert_includes compose, "GOOGLE_WORKSPACE_DOMAINS: ${GOOGLE_WORKSPACE_DOMAINS:?set GOOGLE_WORKSPACE_DOMAINS}"
        assert_includes compose_environment, "GOOGLE_CLIENT_ID=replace-with-google-client-id"
        assert_includes compose_environment, "GOOGLE_CLIENT_SECRET=replace-with-google-client-secret"
        assert_includes compose_environment, "GOOGLE_WORKSPACE_DOMAINS=example.com"
        assert_includes render, "key: GOOGLE_CLIENT_ID"
        assert_includes render, "key: GOOGLE_CLIENT_SECRET"
        assert_includes render, "key: GOOGLE_WORKSPACE_DOMAINS"
      end
    end

    def refute_path(destination, relative)
      refute destination.join(relative).exist?, "expected #{relative} to be absent"
    end

    def assert_clean_of_institutional_code(destination)
      assert_clean_of_institutional_clients(destination)
      forbidden = /google|omniauth|GOOGLE_/i
      assert_no_text_match(destination, forbidden)
    end

    def assert_clean_of_institutional_clients(destination)
      assert_no_text_match(destination, /CANVAS_|canvas_(?:client|api|base_url|access_token)|populi|airtable|watermark/i)
    end

    def assert_no_text_match(destination, pattern)
      matches = []
      destination.find do |path|
        next unless path.file?
        text = path.binread
        next if text.include?("\0") || !text.force_encoding(Encoding::UTF_8).valid_encoding?
        matches << path.relative_path_from(destination).to_s if text.match?(pattern)
      end
      assert_empty matches, "unexpected #{pattern.inspect} in #{matches.join(', ')}"
    end
end
