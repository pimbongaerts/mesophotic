class ChangePhotosAssociations < ActiveRecord::Migration
  def change
  	drop_table :focusgroups_photos
  	drop_table :fields_photos
  	drop_table :photos_publications
  	drop_table :photos_posts

  	create_table :organisations_photos, id: false do |t|
      t.belongs_to :organisation, index: true
      t.belongs_to :photo, index: true
    end
  	create_table :photos_users, id: false do |t|
      t.belongs_to :photo, index: true
      t.belongs_to :user, index: true
    end

    remove_column :photos, :organisation_id
    remove_column :photos, :user_id

    add_column :photos, :underwater, :boolean, :default => false
	  add_column :photos, :post_id, :integer
	  add_column :photos, :meeting_id, :integer
	  add_column :photos, :publication_id, :integer
  end
end
