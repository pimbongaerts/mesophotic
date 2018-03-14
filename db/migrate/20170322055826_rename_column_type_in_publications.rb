class RenameColumnTypeInPublications < ActiveRecord::Migration[4.2]
  def change
  	add_column :publications, :publication_type, :string
  end
end
