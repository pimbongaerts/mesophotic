# Be sure to restart your server when you modify this file.
#
# Propshaft serves all files in asset paths automatically.
# dartsass-rails compiles SCSS to app/assets/builds/.

# Add vendor stylesheets path for RailsAdmin pre-compiled CSS and Bootstrap Icons.
Rails.application.config.assets.paths << Rails.root.join("vendor/assets/stylesheets")
Rails.application.config.assets.paths << Rails.root.join("vendor/assets/fonts")
