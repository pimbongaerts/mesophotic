class DropTypeColumnFromPublications < ActiveRecord::Migration
  def change
  	remove_column :publications, :type
  end
end
