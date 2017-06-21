class ChangeColumnNames < ActiveRecord::Migration
  def change
  	rename_column :publications, :coralreef, :mce
  	rename_column :publications, :upper_depth, :min_depth
  	rename_column :publications, :lower_depth, :max_depth
  end
end
