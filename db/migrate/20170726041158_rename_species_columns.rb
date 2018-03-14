class RenameSpeciesColumns < ActiveRecord::Migration[4.2]
  def change
  	rename_column :species, :url_fishbase, :fishbase_webid
  	rename_column :species, :url_aims, :aims_webid
  	rename_column :species, :url_coraltraits, :coraltraits_webid
  end
end
