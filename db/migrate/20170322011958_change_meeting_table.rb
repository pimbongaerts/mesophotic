class ChangeMeetingTable < ActiveRecord::Migration
  def change
  	add_column :meetings, :country, :string
  	remove_column :meetings, :location_id
  end
end
