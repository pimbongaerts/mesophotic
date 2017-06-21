class DropExpertiseTable < ActiveRecord::Migration
  def change
  	drop_table :expertises
  end
end
