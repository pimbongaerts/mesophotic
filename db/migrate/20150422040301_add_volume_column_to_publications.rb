class AddVolumeColumnToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :volume, :string
  end
end
