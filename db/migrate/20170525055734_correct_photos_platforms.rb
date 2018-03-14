class CorrectPhotosPlatforms < ActiveRecord::Migration[4.2]
  def change
   	drop_table :platforms_photos

   	create_table :photos_platforms, id: false do |t|
      t.belongs_to :photo, index: true
      t.belongs_to :platform, index: true
    end
  end
end
