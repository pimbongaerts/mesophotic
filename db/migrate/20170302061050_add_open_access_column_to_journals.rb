class AddOpenAccessColumnToJournals < ActiveRecord::Migration
  def change
  	add_column :journals, :open_access, :boolean
  end
end
