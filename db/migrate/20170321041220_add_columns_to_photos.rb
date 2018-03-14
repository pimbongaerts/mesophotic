class AddColumnsToPhotos < ActiveRecord::Migration[4.2]
  def change
    add_column :photos, :description, :string
    add_column :photos, :expedition_id, :integer
    add_column :photos, :organisation_id, :integer
  end
end
