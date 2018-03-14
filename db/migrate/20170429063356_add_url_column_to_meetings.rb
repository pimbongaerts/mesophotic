class AddUrlColumnToMeetings < ActiveRecord::Migration[4.2]
  def change
  	add_column :meetings, :url, :string
  	add_column :meetings, :venue, :string
  end
end
