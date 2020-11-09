class AddContributorIdToPublications < ActiveRecord::Migration[5.2]
  def change
  	add_column :publications, :contributor_id, :integer, null: true
  end
end
