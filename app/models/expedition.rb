# == Schema Information
#
# Table name: expeditions
#
#  id                          :integer          not null, primary key
#  title                       :string
#  year                        :integer
#  start_date                  :date
#  end_date                    :date
#  url                         :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  description                 :text
#  featured_image_file_name    :string
#  featured_image_content_type :string
#  featured_image_file_size    :integer
#  featured_image_updated_at   :datetime
#  featured_image_credits      :string
#

class Expedition < ApplicationRecord
  # constants
  # attributes

  # associations
  has_and_belongs_to_many :users
  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :platforms
  has_and_belongs_to_many :fields
  has_and_belongs_to_many :focusgroups
  has_and_belongs_to_many :locations
  has_many :posts, as: :postable
  has_many :photos
  has_one_attached :featured_image
  has_attached_file :featured_image,
                    styles: { large: '1024x768>',
                              medium: '640x480>',
                              thumb: '160x120>' },
                    default_url: 'no_featured_image.png'

  # validations
  validates :title, presence: true
  validates :featured_image, content_type: ['image/jpeg', 'imge/jpg']
  
  # callbacks
  # other
  # class methods
  # instance methods
end
