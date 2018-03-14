class CreateObservations < ActiveRecord::Migration[4.2]
  def change
    create_table :observations do |t|
      t.references :observable, polymorphic: true, index: true
      t.integer :species_id
      t.integer :location_id
      t.integer :site_id
      t.integer :user_id
      t.integer :depth
      t.timestamps 
    end
  end
end
