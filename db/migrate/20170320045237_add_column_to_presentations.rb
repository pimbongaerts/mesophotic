class AddColumnToPresentations < ActiveRecord::Migration
  def change
  	add_column :presentations, :meeting_id, :integer
  end
end
