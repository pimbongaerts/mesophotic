class Admin::FieldsController < Admin::BaseController
	def destroy
        @publication = Publication.find(params[:publication_id])
        @publication.fields.delete(params[:id])
        redirect_back fallback_location: root_path,
        			  notice: 'Category was successfully removed.'
	end
end
