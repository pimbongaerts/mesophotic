class AddExternalColumnToPublications < ActiveRecord::Migration[5.1]
  def change
  	add_column :publications, :external_id, :text
  end
end
