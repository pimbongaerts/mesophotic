class CreateJoinTablePresentationUser < ActiveRecord::Migration
  def change
    create_join_table :presentations, :users do |t|
      # t.index [:presentation_id, :user_id]
      # t.index [:user_id, :presentation_id]
    end
  end
end
