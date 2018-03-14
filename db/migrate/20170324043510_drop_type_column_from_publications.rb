class DropTypeColumnFromPublications < ActiveRecord::Migration[4.2]
  def change
  	remove_column :publications, :type
  end
end
