class ChangePublicationColumns < ActiveRecord::Migration[4.2]
  def change
  	add_column :publications, :book_authors, :string
  	#drop_table :publication_types
  end
end
