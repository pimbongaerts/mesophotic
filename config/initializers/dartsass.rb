# Silence Sass deprecation warnings from Bootstrap 5.x.
# Bootstrap uses @import, darken(), red/green/blue(), if(), and other
# Dart Sass 2.x features that are deprecated in Dart Sass 3.0.
# These cannot be fixed until Bootstrap migrates to @use/@forward.
# See: https://github.com/twbs/bootstrap/issues/40962

Rails.application.config.dartsass.build_options = %w[
  --silence-deprecation=import
  --silence-deprecation=global-builtin
  --silence-deprecation=color-functions
  --silence-deprecation=if-function
]
