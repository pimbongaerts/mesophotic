class AddSocialMediaHandles < ActiveRecord::Migration[6.1]
  def change
    rename_column :users, :twitter, :twitter_handle
    add_column :users, :mastodon_handle, :string
    add_column :users, :bluesky_handle, :string
    add_column :users, :threads_handle, :string
  end
end
