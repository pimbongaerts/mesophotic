class AddJournalWebsiteColumn < ActiveRecord::Migration[5.1]
  def change
  	add_column :journals, :website, :text
  end
end
