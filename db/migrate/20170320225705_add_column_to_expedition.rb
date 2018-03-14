class AddColumnToExpedition < ActiveRecord::Migration[4.2]
  def change
  	add_column :expeditions, :featured_image_credits, :string
  end
end
