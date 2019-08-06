class AddRegionFieldToSpeciesTable < ActiveRecord::Migration[5.2]
  def change
  	add_column :species, :region, :string
  end
end
