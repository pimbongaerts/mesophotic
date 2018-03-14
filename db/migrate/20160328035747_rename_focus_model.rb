class RenameFocusModel < ActiveRecord::Migration[4.2]
  def self.up
      rename_table :focus, :focus_area
  end
  def self.down
      rename_table :focus_area, :focus
  end
end
