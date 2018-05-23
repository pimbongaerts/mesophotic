class CreatePublicationsSpeciesJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :publications, :species do |t|
      t.index :publication_id
      t.index :species_id
    end
  end
end
