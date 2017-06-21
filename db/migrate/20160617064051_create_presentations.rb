class CreatePresentations < ActiveRecord::Migration
  def change
    create_table :presentations do |t|
      t.string :title
      t.text :abstract
      t.text :authors
      t.boolean :oral
      t.string :session
      t.string :date
      t.string :time
      t.string :location
      t.integer :poster_id

      t.timestamps null: false
    end
  end
end
