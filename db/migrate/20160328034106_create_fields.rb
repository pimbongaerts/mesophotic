class CreateFields < ActiveRecord::Migration[4.2]
  def change
    create_table :fields do |t|
      t.string :description

      t.timestamps null: false
    end
  end
end
