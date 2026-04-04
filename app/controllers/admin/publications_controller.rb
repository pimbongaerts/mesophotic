class Admin::PublicationsController < Admin::BaseController
  before_action :require_admin!

  def dashboard
	  @publications = Publication.includes(:users, :journal, pdf_attachment: :blob).page(params[:page])
  end
end
