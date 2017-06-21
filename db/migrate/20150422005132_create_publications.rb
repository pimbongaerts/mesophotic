class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|

      t.timestamps null: false
    end
  end
end
