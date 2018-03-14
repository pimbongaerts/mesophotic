class LinkPhotoModelHabtm < ActiveRecord::Migration[4.2]
  def change
  	create_table :photos_posts, id: false do |t|
      t.belongs_to :photo, index: true
      t.belongs_to :post, index: true
    end
  	create_table :focusgroups_photos, id: false do |t|
      t.belongs_to :focusgroup, index: true
      t.belongs_to :photo, index: true
    end
   	create_table :fields_photos, id: false do |t|
      t.belongs_to :field, index: true
      t.belongs_to :photo, index: true
    end
   	create_table :platforms_photos, id: false do |t|
      t.belongs_to :platform, index: true
      t.belongs_to :photo, index: true
    end
   	create_table :photos_publications, id: false do |t|
      t.belongs_to :photo, index: true
      t.belongs_to :publication, index: true
    end
  end
end
