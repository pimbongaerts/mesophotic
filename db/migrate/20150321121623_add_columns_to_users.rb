class AddColumnsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :title, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :website, :string
    add_column :users, :alt_website, :string
    add_column :users, :google_scholar, :string
    add_column :users, :address, :text 
    add_column :users, :department, :string
    add_column :users, :other_organizations, :text
  end
end
