ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'logger'         # Ensure Logger is available before bootsnap caches load paths.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
