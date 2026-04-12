class ChangeLocationCoordinateDefaultsToNull < ActiveRecord::Migration[8.1]
  def change
    change_column_default :locations, :latitude, from: 0.0, to: nil
    change_column_default :locations, :longitude, from: 0.0, to: nil
  end
end
