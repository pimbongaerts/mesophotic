source 'https://rubygems.org'

# Standard Rails gems
gem 'rails', '~> 6.1.0'
gem 'bcrypt'
gem 'bootsnap'
gem 'jbuilder'
gem 'listen'
gem 'puma'
gem 'puma_worker_killer'
gem 'sassc-rails'
gem 'turbolinks'
gem 'terser'

# RailsBricks gems
gem 'bootstrap', '~> 5.3'
gem 'devise', '>= 4.6.0'
gem 'friendly_id'
gem 'kaminari'
gem 'redcarpet'

# Added Rails gems
gem 'country_select'
gem 'figaro'
gem 'histogram'
gem 'paper_trail'
gem 'rails_admin'
gem 'render_async'
gem 'switch_user'

# ActiveStorage, wont be required after we migrate to Rails 6+
gem 'active_storage_validations'
gem 'image_processing', '~> 1.2'
gem 'mini_magick'

# Backup
gem 'aws-sdk-rails'
gem 'aws-sdk-s3'
gem 'whenever', require: false

group :production do
  # Monitoring
  gem 'newrelic_rpm'
end

# RailsBricks development gems
group :development, :test do
  gem 'annotate'
  gem 'byebug'
  gem 'rails-erd'
  gem 'spring'
  gem 'sqlite3', '~> 1.6.9'
end

group :development do
  gem 'web-console'

  # Profiling
  gem 'derailed_benchmarks'
  gem 'flamegraph'
  gem 'memory_profiler'
  gem 'rack-mini-profiler', require: false
  gem 'stackprof'
end
