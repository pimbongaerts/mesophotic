class AddOpenAccessColumnToJournals < ActiveRecord::Migration[4.2]
  def change
  	add_column :journals, :open_access, :boolean
  end
end
