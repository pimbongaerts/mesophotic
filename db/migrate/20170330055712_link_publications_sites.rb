class LinkPublicationsSites < ActiveRecord::Migration
  	create_table :publications_sites, id: false do |t|
      t.belongs_to :publication, index: true
      t.belongs_to :site, index: true
    end
end
