class AddAttachmentPdfToPresentations < ActiveRecord::Migration[4.2]
  def self.up
    change_table :presentations do |t|
      t.attachment :pdf
    end
  end

  def self.down
    remove_attachment :presentations, :pdf
  end
end
