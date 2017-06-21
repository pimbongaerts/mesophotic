class AddColumnToObservation < ActiveRecord::Migration
  def change
  	add_column :observations, :depth_estimate, :boolean
  end
end
