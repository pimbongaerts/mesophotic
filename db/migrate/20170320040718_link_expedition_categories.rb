class LinkExpeditionCategories < ActiveRecord::Migration[4.2]
  def change
  	create_table :expeditions_platforms, id: false do |t|
      t.belongs_to :expedition, index: true
      t.belongs_to :platform, index: true
    end
  	create_table :expeditions_fields, id: false do |t|
      t.belongs_to :expedition, index: true
      t.belongs_to :field, index: true
    end
   	create_table :expeditions_focusgroups, id: false do |t|
      t.belongs_to :expedition, index: true
      t.belongs_to :focusgroup, index: true
    end
   	create_table :expeditions_locations, id: false do |t|
      t.belongs_to :expedition, index: true
      t.belongs_to :location, index: true
    end
  end
end
