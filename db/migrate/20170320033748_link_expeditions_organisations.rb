class LinkExpeditionsOrganisations < ActiveRecord::Migration
  def change
  	create_table :expeditions_organisations, id: false do |t|
      t.belongs_to :expedition, index: true
      t.belongs_to :organisation, index: true
    end
  end
end
