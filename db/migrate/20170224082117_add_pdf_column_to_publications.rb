class AddPdfColumnToPublications < ActiveRecord::Migration[4.2]
  def change
  	add_attachment :publications, :pdf
  end
end
