class CreateEezs < ActiveRecord::Migration[8.1]
  def change
    create_table :eezs do |t|
      t.integer :mrgid, null: false
      t.string :geoname, null: false
      t.string :sovereign, null: false
      t.string :territory, null: false

      t.timestamps
    end

    add_index :eezs, :mrgid, unique: true
    add_index :eezs, :sovereign
  end
end
