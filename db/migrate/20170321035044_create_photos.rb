class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :credit
      t.integer :user_id
      t.integer :photographer_id
      t.integer :depth
      t.boolean :contains_species      
      t.integer :location_id
      t.integer :site_id
      t.timestamps null: false
    end
  end
end
