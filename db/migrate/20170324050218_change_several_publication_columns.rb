class ChangeSeveralPublicationColumns < ActiveRecord::Migration[4.2]
  def change
  	remove_column :publications, :ISSN
  	#rename_column :publications, :article_title, :title
  end
end
