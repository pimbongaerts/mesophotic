class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :research_interests, :text
    add_column :users, :organisation_id, :integer
  end
end
