class CreateTablesLinkingToPublications < ActiveRecord::Migration
  def change
    create_table :platforms_publications, id: false do |t|
      t.belongs_to :platform, index: true
      t.belongs_to :publication, index: true
    end
    create_table :fields_publications, id: false do |t|
      t.belongs_to :field, index: true
      t.belongs_to :publication, index: true
    end
    create_table :focuses_publications, id: false do |t|
      t.belongs_to :focus, index: true
      t.belongs_to :publication, index: true
    end
    create_table :locations_publications, id: false do |t|
      t.belongs_to :location, index: true
      t.belongs_to :publication, index: true
    end
  end
end
