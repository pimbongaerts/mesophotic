class AddFieldsToPublications < ActiveRecord::Migration[4.2]
  def change
    # Core fields
    add_column :publications, :authors, :text
    add_column :publications, :publication_year, :integer
    add_column :publications, :title, :string
    add_column :publications, :journal_id, :integer
    add_column :publications, :issue, :string
    add_column :publications, :pages, :string
    # Optional fields
    add_column :publications, :DOI, :string
    add_column :publications, :ISSN, :string
    add_column :publications, :url, :string
    add_column :publications, :book_title, :string
    add_column :publications, :book_publisher, :string
    # Extra information
    add_column :publications, :abstract, :text
    add_column :publications, :contents, :text
  end
end
