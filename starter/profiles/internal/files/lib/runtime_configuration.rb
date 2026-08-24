# Internal profile validates its installed authentication adapter.
require "uri"

module RuntimeConfiguration
  ALLOWED_AUTH_METHODS = %w[google].freeze
  ALLOWED_STORAGE_SERVICES = %w[local s3].freeze
  ALLOWED_MAIL_METHODS = %w[none smtp].freeze

  class Error < StandardError; end

  def self.validate!(environment: ENV)
    invalid = invalid_names(environment:)
    raise Error, "Missing or invalid configuration: #{invalid.join(', ')}" if invalid.any?
    true
  end

  def self.invalid_names(environment: ENV)
    invalid = []
    methods = list(environment.fetch("AUTH_METHODS", "google"))
    invalid << "AUTH_METHODS" if methods.empty? || (methods - ALLOWED_AUTH_METHODS).any?
    return invalid unless environment.fetch("RAILS_ENV", "development") == "production"

    require_names(invalid, environment, %w[APP_HOST DATABASE_URL FORCE_SSL SECRET_KEY_BASE STORAGE_SERVICE MAIL_DELIVERY_METHOD])
    invalid << "APP_HOST" unless valid_host?(environment["APP_HOST"])
    invalid << "DATABASE_URL" unless valid_database_url?(environment["DATABASE_URL"])
    invalid << "FORCE_SSL" unless %w[0 1 false true].include?(environment["FORCE_SSL"])
    invalid << "SECRET_KEY_BASE" if environment["SECRET_KEY_BASE"].to_s.length < 64

    storage = environment["STORAGE_SERVICE"].to_s
    invalid << "STORAGE_SERVICE" unless ALLOWED_STORAGE_SERVICES.include?(storage)
    if storage == "local"
      require_names(invalid, environment, %w[ACTIVE_STORAGE_ROOT])
    elsif storage == "s3"
      require_names(invalid, environment, %w[S3_BUCKET S3_REGION AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY])
    end

    mail = environment["MAIL_DELIVERY_METHOD"].to_s
    invalid << "MAIL_DELIVERY_METHOD" unless ALLOWED_MAIL_METHODS.include?(mail)
    require_names(invalid, environment, %w[SMTP_ADDRESS SMTP_PORT SMTP_DOMAIN]) if mail == "smtp"

    require_names(invalid, environment, %w[GOOGLE_CLIENT_ID GOOGLE_CLIENT_SECRET GOOGLE_WORKSPACE_DOMAINS]) if methods.include?("google")
    invalid.uniq.sort
  end

  def self.list(value)
    value.to_s.split(",").map(&:strip).reject(&:empty?)
  end
  private_class_method :list

  def self.require_names(invalid, environment, names)
    invalid.concat(names.select { |name| environment[name].to_s.strip.empty? })
  end
  private_class_method :require_names

  def self.valid_host?(value)
    value = value.to_s
    uri = URI.parse("https://#{value}")
    !value.empty? && uri.host == value && uri.path.empty?
  rescue URI::InvalidURIError
    false
  end
  private_class_method :valid_host?

  def self.valid_database_url?(value)
    uri = URI.parse(value.to_s)
    %w[postgres postgresql].include?(uri.scheme) && !uri.host.to_s.empty? && uri.path.to_s.length > 1
  rescue URI::InvalidURIError
    false
  end
  private_class_method :valid_database_url?
end
