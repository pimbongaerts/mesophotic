class Admin::FieldsController < Admin::BaseController
	def destroy
        @publication = Publication.find(params[:publication_id])
        @publication.fields.delete(params[:id])
        redirect_to :back, notice: 'Category was successfully removed.'
	end
end
