class CreateTableLinkingFocusgroupAndPublications < ActiveRecord::Migration
  def change
    create_table :focusgroups_publications, id: false do |t|
      t.belongs_to :focusgroup, index: true
      t.belongs_to :publication, index: true
    end
  end
end
