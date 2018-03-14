class AddColumnsToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :upper_depth, :integer
    add_column :publications, :lower_depth, :integer
    add_column :publications, :new_species, :boolean
    add_column :publications, :filename, :string
  end
end
