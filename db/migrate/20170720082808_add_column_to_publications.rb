class AddColumnToPublications < ActiveRecord::Migration[4.2]
  def change
  	add_column :publications, :behind_contents, :text
  end
end
