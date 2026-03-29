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
      @user.admin = (new_params[:admin] == "1") if new_params.key?(:admin)
      @user.editor = (new_params[:editor] == "1") if new_params.key?(:editor)
      @user.locked = (new_params[:locked] == "1" || new_params[:locked] == "true") if new_params.key?(:locked)
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
    :admin,
    :locked,
    :twitter,
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
