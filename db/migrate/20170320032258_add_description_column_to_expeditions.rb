class AddDescriptionColumnToExpeditions < ActiveRecord::Migration[4.2]
  def change
  	add_column :expeditions, :description, :text
  end
end
