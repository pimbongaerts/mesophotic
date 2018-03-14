class CreateSites < ActiveRecord::Migration[4.2]
  def change
    create_table :sites do |t|
      t.string :site_name
      t.decimal  "latitude", :precision => 15, :scale => 10, :default => 0.0
      t.decimal  "longitude", :precision => 15, :scale => 10, :default => 0.0
      t.boolean :estimated
      t.integer :location_id
      
      t.references :siteable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
