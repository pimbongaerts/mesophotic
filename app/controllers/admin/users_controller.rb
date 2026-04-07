class Admin::UsersController < Admin::BaseController
  before_action :require_admin!
  before_action :set_user, only: [
    :show,
    :edit,
    :update,
    :destroy
  ]

  def index
    @users = User.search_and_order(params[:search], params[:page])
  end

  def show
    redirect_to edit_admin_user_path(params[:id])
  end

  def edit
  end

  def update
    old_email = @user.email
    new_params = user_params.dup

    @user.email = new_params[:email].strip if new_params[:email].present?
    @user.password = new_params[:password] if new_params[:password].present?
    @user.password_confirmation = new_params[:password_confirmation] if new_params[:password_confirmation].present?

    if current_user.id != @user.id
      role = params[:user][:role]
      @user.role = role if role.present? && role.in?(%w[member editor admin])
      locked = params[:user][:locked]
      @user.locked = (locked == "1" || locked == "true") if locked.present?
    end

    if @user.valid?
      @user.skip_reconfirmation!
      @user.save
      redirect_to edit_admin_user_path(@user), notice: "#{@user.email} updated."
    else
      flash[:alert] = "#{old_email} couldn't be updated."
      render :edit
    end
  end

  def destroy
    if current_user.id == @user.id
      redirect_to admin_users_path, alert: "You cannot delete your own account."
    else
      email = @user.email
      @user.destroy
      redirect_to admin_users_path, notice: "#{email} has been deleted."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue
    flash[:alert] = "The user with an id of #{params[:id]} doesn't exist."
    redirect_to admin_users_path
  end

  def user_params
    params.require(:user).permit(
    :email,
    :password,
    :password_confirmation,
    :twitter_handle,
    :mastodon_handle,
    :bluesky_handle,
    :threads_handle,
    :title,
    :first_name,
    :last_name,
    :phone,
    :website,
    :alt_website,
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
    {:publication_ids => []}
    )
  end
end
