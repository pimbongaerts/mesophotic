class AddLocationColumnToPhoto < ActiveRecord::Migration[5.1]
  def change
  	add_column :photos, :showcases_location, :boolean, default: true
  end
end
