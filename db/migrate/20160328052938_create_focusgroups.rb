class CreateFocusgroups < ActiveRecord::Migration[4.2]
  def change
    create_table :focusgroups do |t|
      t.string :description

      t.timestamps null: false
    end
  end
end
