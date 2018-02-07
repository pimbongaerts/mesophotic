class Admin::LocationsController < Admin::BaseController
	def destroy
	    @publication = Publication.find(params[:publication_id])
	    @publication.locations.delete(params[:id])
	    redirect_back fallback_location: root_path, 
	    			  notice: 'Category was successfully removed.'
	end
end