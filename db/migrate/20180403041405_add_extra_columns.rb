class AddExtraColumns < ActiveRecord::Migration[5.1]
  def change
  	add_column :publications, :tme, :boolean, default: false
  	add_column :journals, :fullname, :text
  	add_column :photos, :media_gallery, :boolean, default: false
  end
end
