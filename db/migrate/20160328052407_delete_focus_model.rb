class DeleteFocusModel < ActiveRecord::Migration[4.2]
  def up
    drop_table :focus_area
    drop_table :focuses_publications
  end
end
