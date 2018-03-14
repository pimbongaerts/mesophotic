class AddVolumeColumnToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :volume, :string
  end
end
