class CreateSpecies < ActiveRecord::Migration[4.2]
  def change
    create_table :species do |t|
      t.string :name
      t.integer :focusgroup_id
      t.string :url_fishbase
      t.string :url_aims
      t.string :url_coraltraits

      t.timestamps null: false
    end
  end
end
