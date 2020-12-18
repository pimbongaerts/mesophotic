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
  has_one_attached :featured_image

  # validations
  validates :title, presence: true
  validates :country, presence: true, length: { minimum: 2, maximum: 2 }
  validates :featured_image, content_type: ['image/jpeg', 'image/jpg']

  # callbacks
  # other
  # class methods
  # instance methods
end
