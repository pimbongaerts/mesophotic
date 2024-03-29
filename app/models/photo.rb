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
  has_one_attached :image

  paginates_per 30

  # validations
  validates :image, attached: true, content_type: /\Aimage\/.*\z/

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

  def place_data z
    location.try(:place_data, z) || site.try(:place_data, z)
  end

  def has_place?
    location_id.present? || site_id.present?
  end
end
