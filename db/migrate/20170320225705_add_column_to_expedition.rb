class AddColumnToExpedition < ActiveRecord::Migration
  def change
  	add_column :expeditions, :featured_image_credits, :string
  end
end
