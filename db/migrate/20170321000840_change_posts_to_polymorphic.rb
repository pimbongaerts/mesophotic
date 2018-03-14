class ChangePostsToPolymorphic < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :postable_id, :integer
    add_column :posts, :postable_type, :string

    add_index :posts, [:postable_type, :postable_id]
  end
end
