class AddAttachmentFeaturedImageToExpeditions < ActiveRecord::Migration
  def self.up
    change_table :expeditions do |t|
      t.attachment :featured_image
    end
  end

  def self.down
    remove_attachment :expeditions, :featured_image
  end
end
