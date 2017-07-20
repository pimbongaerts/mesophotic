class AddColumnToPublications < ActiveRecord::Migration
  def change
  	add_column :publications, :behind_contents, :text
  end
end
