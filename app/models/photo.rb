# == Schema Information
#
# Table name: photos
#
#  id                 :integer          not null, primary key
#  credit             :string
#  photographer_id    :integer
#  depth              :integer
#  contains_species   :boolean
#  location_id        :integer
#  site_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  description        :string
#  expedition_id      :integer
#  underwater         :boolean          default(FALSE)
#  post_id            :integer
#  meeting_id         :integer
#  publication_id     :integer
#

class Photo < ActiveRecord::Base
  # constants
  # attributes
  # associations
  has_and_belongs_to_many :platforms
  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :users
  belongs_to :post
  belongs_to :meeting
  belongs_to :publication
  belongs_to :location
  belongs_to :site
  belongs_to :expedition
  belongs_to :photographer, 
             :class_name => 'User', 
             :foreign_key => 'photographer_id'

  has_attached_file :image, presence: true,
                            default_url: 'no_image.png',
                            styles: { large: '1024x768>',
                                      medium: '640x480>',
                                      thumb: '160x120>',
                                      compo: '340x227^'},
                            convert_options: {
                                      compo: " -gravity center -crop '340x227+0+0'" }

  # validations
  validates_attachment :image, 
                       presence: true,
                       content_type: { content_type: 'image/jpeg' }

  # callbacks
  # other
  # class methods
  # instance methods
end