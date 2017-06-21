class RemovePolymorphismFromSites < ActiveRecord::Migration
  def change
  	remove_reference :sites, :siteable
  end
end
