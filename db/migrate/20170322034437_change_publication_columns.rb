class ChangePublicationColumns < ActiveRecord::Migration
  def change
  	add_column :publications, :book_authors, :string
  	#drop_table :publication_types
  end
end
