# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
min_threads = ENV.fetch("RAILS_MIN_THREADS") { 1 }
max_threads = ENV.fetch("RAILS_MAX_THREADS") { 3 }
threads min_threads, max_threads

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT") { 8765 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
workers ENV.fetch("WEB_CONCURRENCY") { 1 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
preload_app!

# Restart workers that exceed memory limit (in bytes). Checks every 30 seconds.
before_fork do
  require 'puma_worker_killer'
  PumaWorkerKiller.config do |config|
    config.ram           = 512 # MB - restart worker if total RAM exceeds this
    config.frequency     = 30  # seconds between checks
    config.percent_usage = 0.9 # restart at 90% of ram limit
    config.rolling_restart_frequency = 6 * 3600 # force restart every 6 hours
  end
  PumaWorkerKiller.start
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
