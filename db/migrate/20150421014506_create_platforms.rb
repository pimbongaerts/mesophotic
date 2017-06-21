class CreatePlatforms < ActiveRecord::Migration
  def change
    create_table :platforms do |t|
      t.string :description
      t.timestamps null: false
    end

    create_table :platforms_users, id: false do |t|
      t.belongs_to :platform, index: true
      t.belongs_to :user, index: true
    end
  end
end
