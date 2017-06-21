class CreateFocus < ActiveRecord::Migration
  def change
    create_table :focus do |t|
      t.string :description

      t.timestamps null: false
    end
  end
end
