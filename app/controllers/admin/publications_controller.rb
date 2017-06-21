class Admin::PublicationsController < Admin::BaseController
  before_filter :require_admin!
  before_action :set_post, only: [
    :edit,
    :update,
    :destroy
  ]

  def dashboard
	@publications = Publication.all.paginate(:page => params[:page], 
											 :per_page => 20)
  end

  def destroy

  end



end