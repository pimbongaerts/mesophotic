class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :reject_locked!, if: :devise_controller?


  # Devise permitted params
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :email,
      :password,
      :password_confirmation,
      :title,
      :first_name,
      :last_name,
      :phone,
      :website,
      :alt_website,
      :google_scholar,
      :twitter,
      :address,
      :department,
      :organisation_id,
      :new_organisation_name,
      :other_organizations,
      :profile_picture,
      :country,
      :research_interests,
      {:expertise_ids => []},
      {:platform_ids => []},
      {:publication_ids => []}
    ])

    devise_parameter_sanitizer.permit(:account_update, keys: [
      :email,
      :password,
      :password_confirmation,
      :current_password,
      :title,
      :first_name,
      :last_name,
      :phone,
      :website,
      :alt_website,
      :google_scholar,
      :twitter,
      :address,
      :department,
      :organisation_id,
      :new_organisation_name,
      :other_organizations,
      :profile_picture,
      :country,
      :research_interests,
      {:expertise_ids => []},
      {:platform_ids => []},
      {:publication_ids => []}
    ])
  end

  # Redirects on successful sign in
  def after_sign_in_path_for(resource)
    root_path
  end

  # Auto-sign out locked users
  def reject_locked!
    if current_user && current_user.locked?
      sign_out current_user
      user_session = nil
      current_user = nil
      flash[:alert] = 'Your account is locked.'
      flash[:notice] = nil
      redirect_to root_url
    end
  end
  helper_method :reject_locked!

  # Only permits admin users
  def require_admin!
    authenticate_user!

    if current_user && !current_user.admin?
      redirect_to root_path
    end
  end
  helper_method :require_admin!

  # Only permits editor users
  def require_admin_or_editor!
    authenticate_user!

    if current_user && !current_user.editor? && !@current_user.admin?
      redirect_to root_path
    end
  end

  helper_method :require_admin_or_editor!
end
