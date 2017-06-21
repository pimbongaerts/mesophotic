class AddPdfColumnToPublications < ActiveRecord::Migration
  def change
  	add_attachment :publications, :pdf
  end
end
