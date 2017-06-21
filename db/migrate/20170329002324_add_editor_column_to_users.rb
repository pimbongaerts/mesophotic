class AddEditorColumnToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :editor, :boolean, :default => false
  end
end
