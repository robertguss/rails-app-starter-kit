require Rails.root.join("lib/runtime_configuration")

if Rails.env.production? && ENV["SECRET_KEY_BASE_DUMMY"] != "1"
  RuntimeConfiguration.validate!
end
