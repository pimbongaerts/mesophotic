# Be sure to restart your server when you modify this file.
#
# All Rails 7.1 framework defaults are active via config.load_defaults 7.1
# in config/application.rb. The only override below is for the variant
# processor, which requires libvips on the server to switch to :vips.

# Active Storage variant processor: keep mini_magick until libvips is
# installed on the production server (Dreamhost VPS).
Rails.application.config.active_storage.variant_processor = :mini_magick
