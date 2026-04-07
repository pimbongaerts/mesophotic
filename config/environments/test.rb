Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.enable_reloading = false

  # Eager load in CI, skip locally for speed.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Bullet N+1 detection — raises on any unoptimized query in tests
  config.after_initialize do
    Bullet.enable = true
    Bullet.raise = true

    # HABTM join tables flagged as unused when the parent association is used
    Bullet.add_safelist type: :unused_eager_loading, class_name: "Publication", association: :publications_users

    # Photos require Active Storage attachments which are complex to fixture
    Bullet.add_safelist type: :unused_eager_loading, class_name: "User", association: :photos
    Bullet.add_safelist type: :unused_eager_loading, class_name: "User", association: :photos_users

    # About page eager loads organisation/profile_picture for contributor
    # partial, but fixture users don't match the hardcoded contributor
    # names in the template, so the associations appear unused in tests.
    Bullet.add_safelist type: :unused_eager_loading, class_name: "User", association: :organisation
    Bullet.add_safelist type: :unused_eager_loading, class_name: "User", association: :profile_picture_attachment
  end
end
