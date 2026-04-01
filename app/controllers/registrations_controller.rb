class RegistrationsController < Devise::RegistrationsController
  before_action :permit_params, only: [:create]

  def create
    if verify_turnstile
      super
    else
      build_resource(sign_up_params)
      resource.errors.add(:base, "Captcha verification failed. Please try again.")
      render :new
    end
  end

  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  private

  def verify_turnstile
    token = params['cf-turnstile-response']
    return false if token.blank?

    secret = Rails.application.credentials.dig(:turnstile, :secret_key)
    uri = URI.parse('https://challenges.cloudflare.com/turnstile/v0/siteverify')
    response = Net::HTTP.post_form(uri, secret: secret, response: token)
    result = JSON.parse(response.body)
    result['success']
  rescue StandardError
    false
  end

  def permit_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :first_name,
      :last_name,
      :email,
      :password,
      :password_confirmation,
    ])
  end

  def user_params
    params.require(:user).permit(
    :email,
    :password,
    :password_confirmation,
    :role,
    :locked,
    :title,
    :first_name,
    :last_name,
    :phone,
    :website,
    :alt_website,
    :twitter_handle,
    :mastodon_handle,
    :bluesky_handle,
    :threads_handle,
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
