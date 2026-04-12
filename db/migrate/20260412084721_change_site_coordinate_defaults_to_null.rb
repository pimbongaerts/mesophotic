class ChangeSiteCoordinateDefaultsToNull < ActiveRecord::Migration[8.1]
  def change
    change_column_default :sites, :latitude, from: 0.0, to: nil
    change_column_default :sites, :longitude, from: 0.0, to: nil
  end
end
