# Be sure to restart your server when you modify this file.
#
# All Rails 8.1 framework defaults are active via config.load_defaults 8.1
# in config/application.rb. The only overrides below are for features that
# require server-side changes.

# Active Storage variant processor: keep mini_magick until libvips is
# installed on the production server (Dreamhost VPS).
Rails.application.config.active_storage.variant_processor = :mini_magick

# SQLite strict strings: disabled until raw SQL scopes are audited.
Rails.application.config.active_record.sqlite3_adapter_strict_strings_by_default = false
