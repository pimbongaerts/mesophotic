class AddColumnsToPost < ActiveRecord::Migration[4.2]
  def change
  	add_column :posts, :post_type, :string
  	add_column :posts, :featured_user_id, :integer
  	add_column :posts, :featured_publication_id, :integer
  end
end
