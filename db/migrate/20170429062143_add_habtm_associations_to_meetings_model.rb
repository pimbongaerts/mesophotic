class AddHabtmAssociationsToMeetingsModel < ActiveRecord::Migration[4.2]
  def change
  	create_table :meetings_users, id: false do |t|
      t.belongs_to :meeting, index: true
      t.belongs_to :user, index: true
    end
   	create_table :meetings_organisations, id: false do |t|
      t.belongs_to :meeting, index: true
      t.belongs_to :organisation, index: true
    end
  end
end
