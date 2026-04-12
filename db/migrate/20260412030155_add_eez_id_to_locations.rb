class AddEezIdToLocations < ActiveRecord::Migration[8.1]
  def change
    add_reference :locations, :eez, null: true, foreign_key: true
  end
end
