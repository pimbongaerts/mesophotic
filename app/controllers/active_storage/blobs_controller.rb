class ActiveStorage::BlobsController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob

  def show
    if current_user
      redirect_to @blob.service_url(disposition: params[:disposition])
    else
      redirect_to "/"
    end
  end
end
