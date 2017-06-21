class CorrectLinkTableName < ActiveRecord::Migration
  def change
  	rename_table :expeditioms_users, :expeditions_users
  end
end
