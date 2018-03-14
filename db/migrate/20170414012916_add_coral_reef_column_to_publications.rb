class AddCoralReefColumnToPublications < ActiveRecord::Migration[4.2]
  def change
  	add_column :publications, :coralreef, :boolean, :default => true
  end
end
