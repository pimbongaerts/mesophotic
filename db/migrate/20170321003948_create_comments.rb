class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :commentable, polymorphic: true, index: true
      t.integer :user_id
      t.string :content
      t.boolean :internal
      t.boolean :request
      t.boolean :request_handled
      t.string :request_response
      t.timestamp 
    end
  end
end
