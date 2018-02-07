class Admin::PlatformsController < Admin::BaseController
	def destroy
	    @publication = Publication.find(params[:publication_id])
	    @publication.platforms.delete(params[:id])
	    redirect_back, notice: 'Category was successfully removed.'
	end
end