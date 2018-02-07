class AddColumnToPhoto < ActiveRecord::Migration[5.1]
  def change
 	add_column :photos, :creative_commons, :boolean, default: false
  end
end
