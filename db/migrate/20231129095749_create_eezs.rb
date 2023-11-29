class CreateEezs < ActiveRecord::Migration[5.2]
  def change
    create_table :eezs do |t|
      t.string :name
      t.integer :code

      t.timestamps
    end
  end
end
