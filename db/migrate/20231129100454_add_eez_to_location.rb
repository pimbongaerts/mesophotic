class AddEezToLocation < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :eez_id, :integer, null: true
  end
end
