class ChangeMeetingTable < ActiveRecord::Migration[4.2]
  def change
  	add_column :meetings, :country, :string
  	remove_column :meetings, :location_id
  end
end
