class RemovePolymorphismFromSites < ActiveRecord::Migration[4.2]
  def change
  	remove_reference :sites, :siteable
  end
end
