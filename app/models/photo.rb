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
#  creative_commons   :boolean          default(FALSE)
#  showcases_location :boolean          default(TRUE)
#

class Photo < ApplicationRecord
  # constants
  # attributes
  # associations
  has_and_belongs_to_many :platforms
  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :users
  belongs_to :post, optional: true
  belongs_to :meeting, optional: true
  belongs_to :publication, optional: true
  belongs_to :location, optional: true
  belongs_to :site, optional: true
  belongs_to :expedition, optional: true
  belongs_to :photographer,
             class_name: 'User',
             foreign_key: 'photographer_id',
             optional: true

  has_attached_file :image, presence: true,
                            default_url: 'no_image.png',
                            styles: { large: '1024x768>',
                                      medium: '640x480>',
                                      thumb: '160x120>',
                                      compo: '340x227^'},
                            convert_options: {
                                      compo: " -gravity center -crop '340x227+0+0'" }

  paginates_per 30

  # validations
  validates_attachment :image,
                       presence: true,
                       content_type: { content_type: /\Aimage\/.*\z/ }

  # callbacks
  # other
  # scopes
  scope :showcases_location, lambda { 
    where(showcases_location: true).where(underwater: true).order('created_at DESC')
  }
  scope :media_gallery, lambda {
    #where(media_gallery: true).
    where(creative_commons: true).order('created_at DESC')
  }
  # class methods

  # instance methods
  def previous
    if id == Photo.first.id
      Photo.first
    else
      Photo.where("id < ?", id).last
    end
  end

  def next
    if id == Photo.last.id
      Photo.last
    else
      Photo.where("id > ?", id).first
    end
  end

  def description_truncated
    description.truncate(70)
  end

  def latitude
    location.try(:latitude) || site.try(:latitude)
  end

  def longitude
    location.try(:longitude) || site.try(:longitude)
  end

  def publications
    location.try(:publications) || site.try(:publications)
  end

  def place_name
    location.try(:place_name) || site.try(:place_name)
  end

  def place_id
    location.try(:id) || site.try(:id)
  end

  def place_path
    location.try(:place_path) || site.try(:place_path)
  end

  def z
    location.try(:z) || site.try(:z)
  end
end
