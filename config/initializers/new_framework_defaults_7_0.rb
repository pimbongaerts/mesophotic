# Be sure to restart your server when you modify this file.
#
# This file configures Rails 7.0 framework defaults that need careful migration.
# Safe defaults are already active via config.load_defaults 7.0 in config/application.rb.
#
# Each setting below overrides a 7.0 default back to its 6.1 value.
# Remove each override as you complete the migration for that setting.

# --- Keep 6.1 behavior (migrate later) ---

# Cookie digest: changing this logs out all users and invalidates Devise remember-me tokens.
# Migration path: deploy with SHA1 + rotator, then switch to SHA256 after no rollback risk.
Rails.application.config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA1

# Hash digest: changing this invalidates ETags and cache keys.
# Safe to switch after deploying and clearing production cache.
Rails.application.config.active_support.hash_digest_class = OpenSSL::Digest::SHA1

# Cache format: Rails 6.1 cannot read 7.0-format cache entries.
# Switch to 7.0 after deployment is stable and no rollback to 6.1 is needed.
Rails.application.config.active_support.cache_format_version = 6.1

# Active Storage variant processor: keep mini_magick (vips requires libvips on server).
Rails.application.config.active_storage.variant_processor = :mini_magick

# disable_to_s_conversion: audit .to_s(:format) calls before enabling.
# This only affects Rails' monkey-patched to_s on Date/Time/Array, not plain .to_s.
Rails.application.config.active_support.disable_to_s_conversion = false
