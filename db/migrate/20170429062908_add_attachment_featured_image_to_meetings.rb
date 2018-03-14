class AddAttachmentFeaturedImageToMeetings < ActiveRecord::Migration[4.2]
  def self.up
    change_table :meetings do |t|
      t.attachment :featured_image
      add_column :meetings, :featured_image_credits, :string
    end
  end

  def self.down
    remove_attachment :meetings, :featured_image
    remove_column :meetings, :featured_image_credits, :string
  end
end
