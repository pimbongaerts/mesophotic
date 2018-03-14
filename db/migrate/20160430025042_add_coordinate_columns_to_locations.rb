class AddCoordinateColumnsToLocations < ActiveRecord::Migration[4.2]
  def change
    add_column :locations, :latitude, :decimal, :precision => 15, :scale => 10, :default => 0.0
    add_column :locations, :longitude, :decimal, :precision => 15, :scale => 10, :default => 0.0
  end
end
