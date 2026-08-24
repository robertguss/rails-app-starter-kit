require "fileutils"
require "pathname"
require "yaml"

module Starter
  class Error < StandardError; end

  class Generator
    SOURCE_EXCLUSIONS = %w[
      .bundle .git log node_modules starter storage test-results tmp vendor
    ].freeze
    GENERATED_REMOVALS = %w[
      bin/new bin/starter db/structure.sql docs lib/starter script/verify-profiles test/starter
      public/vite public/vite-dev public/vite-test .amp/portals
    ].freeze
    NAME_PATTERN = /\A[a-z][a-z0-9]*(?:-[a-z0-9]+)*\z/

    attr_reader :manifest, :root

    def initialize(root: Rails.root)
      @root = Pathname(root)
      @manifest = YAML.safe_load(root.join("starter/manifest.yml").read)
    end

    def generate(name:, profile:, destination:, auth: nil, additions: [], lock: true)
      configuration = profile_configuration(profile)
      destination = Pathname(destination).expand_path
      validate_name!(name)
      validate_destination!(destination)
      validate_auth!(configuration, auth)
      recipes = validate_additions!(configuration, additions)

      copy_source(destination)
      GENERATED_REMOVALS.each { |path| FileUtils.rm_rf(destination.join(path)) }
      configuration.fetch("overlays").each { |overlay| copy_tree(root.join("starter", overlay), destination) }
      configure_auth(destination, configuration.fetch("auth"))
      rename_application(destination, name)
      write_receipt(destination, name:, profile:, capabilities: configuration.fetch("capabilities"), recipes: [])
      recipes.each { |recipe| apply_recipe(recipe, destination:, capabilities: configuration.fetch("capabilities")) }
      format_output(destination)
      verify_lock(destination) if lock

      destination
    rescue
      FileUtils.rm_rf(destination) if destination && destination.exist?
      raise
    end

    def apply_recipe(name, destination:, capabilities: nil)
      destination = Pathname(destination).expand_path
      recipe = recipe_configuration(name)
      receipt = read_receipt(destination)
      capabilities ||= receipt.fetch("features")
      recipes = receipt.fetch("recipes")
      return [] if recipes.include?(name)

      requirements = recipe.fetch("requires_any", [])
      if requirements.any? && (requirements & capabilities).empty?
        raise Error, "#{name} requires one of: #{requirements.join(', ')}"
      end

      changes = recipe_changes(name, recipe, destination)
      conflicts = changes.select { |change| change.fetch(:conflict) }
      raise Error, conflicts.map { |change| change.fetch(:conflict) }.join("\n") if conflicts.any?

      changed_paths = []
      files = recipe["files"]
      if files
        source = root.join("starter", files)
        source.find do |path|
          next if path.directory?
          relative = path.relative_path_from(source)
          target = destination.join(relative)
          FileUtils.mkdir_p(target.dirname)
          FileUtils.cp(path, target, preserve: true)
          changed_paths << relative.to_s
        end
      end

      recipe.fetch("insertions", []).each do |insertion|
        path = destination.join(insertion.fetch("path"))
        marker = insertion.fetch("before")
        content = insertion.fetch("content")
        text = path.read
        next if text.lines.any? { |line| line.chomp == content }
        path.write(text.sub("#{marker}\n", "#{content}\n\n#{marker}\n"))
        changed_paths << insertion.fetch("path")
      end

      receipt["recipes"] << name
      write_yaml(destination.join(".starter.yml"), receipt)
      format_output(destination, paths: [ ".starter.yml" ])
      changed_paths << ".starter.yml"
      changed_paths.uniq.sort
    end

    private
      def profile_configuration(profile)
        manifest.fetch("profiles").fetch(profile) do
          raise Error, "unknown profile #{profile.inspect}; choose: #{manifest.fetch('profiles').keys.join(', ')}"
        end
      end

      def recipe_configuration(name)
        manifest.fetch("recipes").fetch(name) do
          raise Error, "unknown recipe #{name.inspect}; choose: #{manifest.fetch('recipes').keys.join(', ')}"
        end
      end

      def validate_name!(name)
        raise Error, "application name must be lowercase kebab-case" unless NAME_PATTERN.match?(name)
      end

      def validate_destination!(destination)
        raise Error, "destination already exists: #{destination}" if destination.exist?
        raise Error, "destination cannot be inside the starter source" if destination.to_s.start_with?("#{root}/")
      end

      def validate_auth!(configuration, auth)
        return unless auth && auth != configuration.fetch("auth")
        raise Error, "profile requires --auth #{configuration.fetch('auth')}; unsupported combinations are not generated"
      end

      def validate_additions!(configuration, additions)
        known = configuration.fetch("capabilities") + manifest.fetch("recipes").keys
        unknown = additions - known
        raise Error, "unsupported additions for this profile: #{unknown.join(', ')}" if unknown.any?
        additions & manifest.fetch("recipes").keys
      end

      def copy_source(destination)
        FileUtils.mkdir_p(destination)
        Dir.children(root).sort.each do |entry|
          next if SOURCE_EXCLUSIONS.include?(entry)
          source = root.join(entry)
          target = destination.join(entry)
          FileUtils.cp_r(source, target, preserve: true)
        end
      end

      def copy_tree(source, destination)
        raise Error, "missing overlay: #{source.relative_path_from(root)}" unless source.directory?
        FileUtils.cp_r("#{source}/.", destination, preserve: true)
      end

      def configure_auth(destination, auth)
        [ ".env.example", "compose.yaml", "compose.env.example" ].each do |relative|
          path = destination.join(relative)
          text = path.read
          text.sub!(/AUTH_METHODS: \$\{AUTH_METHODS:-(?:none|password|google)\}/, "AUTH_METHODS: ${AUTH_METHODS:-#{auth}}")
          text.sub!(/^AUTH_METHODS=(?:none|password|google)$/, "AUTH_METHODS=#{auth}")
          if auth == "google"
            case relative
            when ".env.example"
              text.sub!("AUTH_METHODS=google\n", "AUTH_METHODS=google\nGOOGLE_WORKSPACE_DOMAINS=example.com\n")
              text.sub!("SECRET_KEY_BASE=\n", "SECRET_KEY_BASE=\nGOOGLE_CLIENT_ID=\nGOOGLE_CLIENT_SECRET=\n")
            when "compose.yaml"
              text.sub!(
                "    AUTH_METHODS: ${AUTH_METHODS:-google}\n",
                "    AUTH_METHODS: ${AUTH_METHODS:-google}\n" \
                  "    GOOGLE_CLIENT_ID: ${GOOGLE_CLIENT_ID:?set GOOGLE_CLIENT_ID}\n" \
                  "    GOOGLE_CLIENT_SECRET: ${GOOGLE_CLIENT_SECRET:?set GOOGLE_CLIENT_SECRET}\n" \
                  "    GOOGLE_WORKSPACE_DOMAINS: ${GOOGLE_WORKSPACE_DOMAINS:?set GOOGLE_WORKSPACE_DOMAINS}\n"
              )
            when "compose.env.example"
              text.sub!(
                "AUTH_METHODS=google\n",
                "AUTH_METHODS=google\n" \
                  "GOOGLE_CLIENT_ID=replace-with-google-client-id\n" \
                  "GOOGLE_CLIENT_SECRET=replace-with-google-client-secret\n" \
                  "GOOGLE_WORKSPACE_DOMAINS=example.com\n"
              )
            end
          end
          path.write(text)
        end

        return unless auth == "google"

        render = destination.join("render.yaml")
        text = render.read
        text.sub!(
          "      - key: SECRET_KEY_BASE\n        sync: false\n",
          "      - key: SECRET_KEY_BASE\n        sync: false\n" \
            "      - key: AUTH_METHODS\n        value: google\n" \
            "      - key: GOOGLE_CLIENT_ID\n        sync: false\n" \
            "      - key: GOOGLE_CLIENT_SECRET\n        sync: false\n" \
            "      - key: GOOGLE_WORKSPACE_DOMAINS\n        sync: false\n"
        )
        render.write(text)
      end

      def rename_application(destination, name)
        replacements = {
          "RailsAppStarterKit" => name.split("-").map(&:capitalize).join,
          "rails_app_starter_kit" => name.tr("-", "_"),
          "rails-app-starter-kit" => name,
          "Rails App Starter Kit" => name.split("-").map(&:capitalize).join(" ")
        }
        destination.find do |path|
          next unless path.file?
          text = path.binread
          next if text.include?("\0") || !text.force_encoding(Encoding::UTF_8).valid_encoding?
          updated = replacements.reduce(text) { |value, (from, to)| value.gsub(from, to) }
          path.binwrite(updated) if updated != text
        end
      end

      def write_receipt(destination, name:, profile:, capabilities:, recipes:)
        receipt = {
          "starter_version" => manifest.fetch("starter_version"),
          "application" => name,
          "profile" => profile,
          "features" => capabilities,
          "recipes" => recipes
        }
        write_yaml(destination.join(".starter.yml"), receipt)
      end

      def write_yaml(path, value)
        path.write(YAML.dump(value))
      end

      def format_output(destination, paths: [ "." ])
        prettier = root.join("node_modules/.bin/prettier")
        raise Error, "Prettier is unavailable; run the starter's .agents/setup first" unless prettier.executable?
        success = system(prettier.to_s, "--write", *paths, chdir: destination.to_s, out: File::NULL)
        raise Error, "could not format generated files" unless success
      end

      def verify_lock(destination)
        lock = destination.join("Gemfile.lock")
        raise Error, "generated Gemfile.lock is missing" unless lock.file?
        dependency_names = destination.join("Gemfile").read.scan(/^gem "([^"]+)"/).flatten
        missing = dependency_names.reject { |name| lock.read.match?(/^  #{Regexp.escape(name)} \(/) }
        raise Error, "generated Gemfile.lock is missing: #{missing.join(', ')}" if missing.any?
      end

      def read_receipt(destination)
        path = destination.join(".starter.yml")
        raise Error, "#{destination} is not a generated app (.starter.yml is missing)" unless path.file?
        YAML.safe_load(path.read)
      end

      def recipe_changes(name, recipe, destination)
        changes = []
        files = recipe["files"]
        if files
          source = root.join("starter", files)
          raise Error, "missing recipe files for #{name}" unless source.directory?
          source.find do |path|
            next if path.directory?
            relative = path.relative_path_from(source)
            target = destination.join(relative)
            changes << { conflict: "#{name} would overwrite #{relative}" } if target.exist?
          end
        end
        recipe.fetch("insertions", []).each do |insertion|
          path = destination.join(insertion.fetch("path"))
          marker = insertion.fetch("before")
          content = insertion.fetch("content")
          if !path.file?
            changes << { conflict: "#{name} requires #{insertion.fetch('path')}" }
          elsif !path.read.include?(marker) && !path.read.lines.any? { |line| line.chomp == content }
            changes << { conflict: "#{name} could not find its insertion point in #{insertion.fetch('path')}" }
          end
        end
        changes
      end
  end
end
