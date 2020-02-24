class RegistrationsController < Devise::RegistrationsController
  before_action :permit_params, only: [:create]

  def new
    super do
      resource.textcaptcha
    end
  end

  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  private

  def permit_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name,
      :last_name,
      :email,
      :password,
      :password_confirmation,
      :textcaptcha_key,
      :textcaptcha_answer,
    ])
  end

  def user_params
    params.require(:user).permit(
    :email,
    :password,
    :password_confirmation,
    :admin,
    :locked,
    :title,
    :first_name,
    :last_name,
    :phone,
    :website,
    :alt_website,
    :twitter,
    :google_scholar,
    :address,
    :department,
    :organisation_id,
    :new_organisation_name,
    :other_organizations,
    :profile_picture,
    :country,
    :research_interests,
    {:platform_ids => []},
    {:publication_ids => []},
    )
  end
end
