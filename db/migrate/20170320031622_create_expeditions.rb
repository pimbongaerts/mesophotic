class CreateExpeditions < ActiveRecord::Migration
  def change
    create_table :expeditions do |t|
      t.string :title
      t.integer :year
      t.date :start_date
      t.date :end_date
      t.string :url

      t.timestamps null: false
    end
  end
end
