# Autoload paths
Rails.application.config.autoload_paths += %W(#{Rails.application.config.root}/lib)
Rails.application.config.autoload_paths += Dir["#{Rails.application.config.root}/lib/**/"]

# Do not swallow errors in after_commit/after_rollback callbacks.
Rails.application.config.active_record.raise_in_transactional_callbacks
