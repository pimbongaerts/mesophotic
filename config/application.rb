require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mesophotic
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Turn off warnings triggered by friendly_id
    I18n.enforce_available_locales = false
    # config.encoding = "utf-8"

    # Test framework
    config.generators.test_framework false

    # Enforce 1/0 bools in sqlite
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end
