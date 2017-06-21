class ChangePublicationTypeColumns < ActiveRecord::Migration
  def change
  	add_column :publications, :publication_format, :string, :default => "article"
  end
end
