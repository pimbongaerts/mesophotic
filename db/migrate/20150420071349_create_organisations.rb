class CreateOrganisations < ActiveRecord::Migration[4.2]
  def change
    create_table :organisations do |t|
      t.string :name
      t.string :country

      t.timestamps null: false
    end
  end
end
