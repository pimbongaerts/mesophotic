class ChangePublicationTypeColumns < ActiveRecord::Migration[4.2]
  def change
  	add_column :publications, :publication_format, :string, :default => "article"
  end
end
