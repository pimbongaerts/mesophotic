class RemoveOldPaperclipColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :expeditions, :featured_image_file_name, :string
    remove_column :expeditions, :featured_image_content_type, :string
    remove_column :expeditions, :featured_image_file_size, :integer
    remove_column :expeditions, :featured_image_updated_at, :datetime

    remove_column :meetings, :featured_image_file_name, :string
    remove_column :meetings, :featured_image_content_type, :string
    remove_column :meetings, :featured_image_file_size, :integer
    remove_column :meetings, :featured_image_updated_at, :datetime

    remove_column :photos, :image_file_name, :string
    remove_column :photos, :image_content_type, :string
    remove_column :photos, :image_file_size, :integer
    remove_column :photos, :image_updated_at, :datetime

    remove_column :presentations, :pdf_file_name, :string
    remove_column :presentations, :pdf_content_type, :string
    remove_column :presentations, :pdf_file_size, :integer
    remove_column :presentations, :pdf_updated_at, :datetime

    remove_column :publications, :pdf_file_name, :string
    remove_column :publications, :pdf_content_type, :string
    remove_column :publications, :pdf_file_size, :integer
    remove_column :publications, :pdf_updated_at, :datetime

    remove_column :users, :profile_picture_file_name, :string
    remove_column :users, :profile_picture_content_type, :string
    remove_column :users, :profile_picture_file_size, :integer
    remove_column :users, :profile_picture_updated_at, :datetime
  end
end
