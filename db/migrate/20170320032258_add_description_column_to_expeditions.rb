class AddDescriptionColumnToExpeditions < ActiveRecord::Migration
  def change
  	add_column :expeditions, :description, :text
  end
end
