class AddCoralReefColumnToPublications < ActiveRecord::Migration
  def change
  	add_column :publications, :coralreef, :boolean, :default => true
  end
end
