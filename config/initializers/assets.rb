# Be sure to restart your server when you modify this file.

# Propshaft serves all files in asset paths automatically (no precompile allowlist needed).

# Exclude SCSS source files — dartsass-rails compiles them to app/assets/builds/.
Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")
