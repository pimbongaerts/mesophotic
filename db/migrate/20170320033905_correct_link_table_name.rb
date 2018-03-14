class CorrectLinkTableName < ActiveRecord::Migration[4.2]
  def change
  	rename_table :expeditioms_users, :expeditions_users
  end
end
