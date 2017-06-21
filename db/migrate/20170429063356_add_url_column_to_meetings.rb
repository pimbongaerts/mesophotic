class AddUrlColumnToMeetings < ActiveRecord::Migration
  def change
  	add_column :meetings, :url, :string
  	add_column :meetings, :venue, :string
  end
end
