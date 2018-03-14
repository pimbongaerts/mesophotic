class LinkPublicationsSites < ActiveRecord::Migration[4.2]
  	create_table :publications_sites, id: false do |t|
      t.belongs_to :publication, index: true
      t.belongs_to :site, index: true
    end
end
