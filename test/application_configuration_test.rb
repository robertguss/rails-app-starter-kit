require "test_helper"

class ApplicationConfigurationTest < ActiveSupport::TestCase
  test "production SSR remains disabled" do
    assert_equal false, InertiaRails.configuration.ssr_enabled
    assert_empty Dir[Rails.root.join("app/frontend/entrypoints/*ssr*")]

    package = JSON.parse(Rails.root.join("package.json").read)
    assert_nil package.fetch("scripts")["ssr"]
  end

  test "operational facilities share one database and one Node-free runtime image" do
    database_configuration = Rails.root.join("config/database.yml").read
    assert_equal 1, database_configuration.scan(/^production:/).size
    refute_match(/queue_database|_queue_/, database_configuration)
    assert_includes Rails.root.join("db/structure.sql").read, "CREATE TABLE public.solid_queue_jobs"

    dockerfile = Rails.root.join("Dockerfile").read
    assert_includes dockerfile, "FROM docker.io/library/node:${NODE_VERSION}-bookworm-slim AS node"
    assert_includes dockerfile, "COPY --from=node /usr/local/ /usr/local/"
    refute_match(/COPY --from=\S*\$\{/, dockerfile)
    runtime_stage = dockerfile.split(/^FROM base$/, -1).last
    assert_includes runtime_stage, 'ENTRYPOINT ["/rails/bin/docker-entrypoint"]'
    assert_includes runtime_stage, "mkdir -p db log storage tmp"
    refute_match(/node|pnpm/i, runtime_stage)

    compose = Rails.root.join("compose.yaml").read
    assert_includes compose, "command: bin/release"
    assert_includes compose, "command: bin/jobs start"

    check = Rails.root.join("bin/check").read
    assert_includes check, "RAILS_ENV=test bin/rails db:test:prepare"
    refute_includes check, "RAILS_ENV=test bin/rails db:prepare"

    %w[backup backup-prune config-check docker-entrypoint release restore restore-drill worker-health].each do |script|
      assert_predicate Rails.root.join("bin", script), :executable?
    end
  end
end
