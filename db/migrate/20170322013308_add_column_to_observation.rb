class AddColumnToObservation < ActiveRecord::Migration[4.2]
  def change
  	add_column :observations, :depth_estimate, :boolean
  end
end
