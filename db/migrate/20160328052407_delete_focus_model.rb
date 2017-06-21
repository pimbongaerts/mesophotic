class DeleteFocusModel < ActiveRecord::Migration
  def up
    drop_table :focus_area
    drop_table :focuses_publications
  end
end
