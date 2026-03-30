class Admin::PublicationsController < Admin::BaseController
  before_action :require_admin!
  before_action :set_post, only: [
    :edit,
    :update,
    :destroy
  ]

  def dashboard
	  @publications = Publication.includes(:users, :journal, pdf_attachment: :blob).page(params[:page])
  end

  def destroy
  end
end
