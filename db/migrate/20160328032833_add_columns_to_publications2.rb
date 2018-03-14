class AddColumnsToPublications2 < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :original_data, :boolean
    add_column :publications, :mesophotic, :boolean
  end
end
