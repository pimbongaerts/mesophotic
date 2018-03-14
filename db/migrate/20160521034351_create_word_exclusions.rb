class CreateWordExclusions < ActiveRecord::Migration[4.2]
  def change
    create_table :word_exclusions do |t|
      t.string :word

      t.timestamps null: false
    end
  end
end
