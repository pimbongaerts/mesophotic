class CreateMeetings < ActiveRecord::Migration[4.2]
  def change
    create_table :meetings do |t|
      t.string :title
      t.integer :year
      t.date :start_date
      t.date :end_date
      t.text :description
      t.integer :location_id

      t.timestamps null: false
    end
  end
end
