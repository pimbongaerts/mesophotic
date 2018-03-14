class AddColumnToPresentations < ActiveRecord::Migration[4.2]
  def change
  	add_column :presentations, :meeting_id, :integer
  end
end
