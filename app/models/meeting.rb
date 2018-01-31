# == Schema Information
#
# Table name: meetings
#
#  id                          :integer          not null, primary key
#  title                       :string
#  year                        :integer
#  start_date                  :date
#  end_date                    :date
#  description                 :text
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  country                     :string
#  featured_image_file_name    :string
#  featured_image_content_type :string
#  featured_image_file_size    :integer
#  featured_image_updated_at   :datetime
#  featured_image_credits      :string
#  url                         :string
#  venue                       :string
#

class Meeting < ApplicationRecord
  # constants
  # attributes

  # associations
  has_many :presentations
  has_many :photos
  has_and_belongs_to_many :users
  has_and_belongs_to_many :organisations
  has_attached_file :featured_image,
                    styles: { large: '1024x768>',
                              medium: '640x480>',
                              thumb: '160x120>' },
                    default_url: 'no_featured_image.png'

  # validations
  validates :title, presence: true
  validates :country, presence: true, length: {minimum: 2, maximum: 2}
  validates_attachment :featured_image,
                       content_type: { content_type: 'image/jpeg' }

  # callbacks
  # other
  # class methods
  # instance methods
end
