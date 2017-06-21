class ChangeSeveralPublicationColumns < ActiveRecord::Migration
  def change
  	remove_column :publications, :ISSN
  	rename_column :publications, :article_title, :title
  end
end