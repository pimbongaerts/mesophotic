class CreateValidations < ActiveRecord::Migration[4.2]
  def change
    create_table :validations do |t|
      t.references :validatable, polymorphic: true, index: true
      t.integer :user_id
      t.timestamps
    end
  end
end
