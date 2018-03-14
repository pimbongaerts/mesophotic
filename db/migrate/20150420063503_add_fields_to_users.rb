class AddFieldsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :research_interests, :text
    add_column :users, :organisation_id, :integer
  end
end
