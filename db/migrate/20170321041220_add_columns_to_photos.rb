class AddColumnsToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :description, :string
    add_column :photos, :expedition_id, :integer
    add_column :photos, :organisation_id, :integer
  end
end
