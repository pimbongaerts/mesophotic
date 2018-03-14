class AddShortDescriptionsToKeywordTables < ActiveRecord::Migration[5.1]
  def change
  	add_column :platforms, :short_description, :text
  	add_column :fields, :short_description, :text
  	add_column :focusgroups, :short_description, :text
  	add_column :locations, :short_description, :text
  end
end
