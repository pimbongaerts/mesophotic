# Disable CSP for RailsAdmin — its layout uses inline scripts without nonces
# (jQuery global setup, importmap shims) that can't be patched without forking.
# RailsAdmin is restricted to admin users only, so this is acceptable.
Rails.application.config.to_prepare do
  RailsAdmin::MainController.content_security_policy(false)
end

RailsAdmin.config do |config|
  config.asset_source = :importmap

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
    redirect_to main_app.root_path unless current_user&.admin?
  end
  config.current_user_method(&:current_user)

  ## == PaperTrail ==
  #config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
