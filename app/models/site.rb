# == Schema Information
#
# Table name: sites
#
#  id            :integer          not null, primary key
#  site_name     :string(255)
#  latitude      :decimal(15, 10)  default(0.0)
#  longitude     :decimal(15, 10)  default(0.0)
#  estimated     :boolean
#  location_id   :integer
#  siteable_type :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Site < ApplicationRecord
  # constants
  # attributes

  # associations
  belongs_to :location # TODO: CHECK
  has_and_belongs_to_many :publications, touch: true
  has_many :photos

  # validations
  validates :latitude , presence: true,
                        numericality: { greater_than_or_equal_to:  -90,
                                        less_than_or_equal_to:  90 }
  validates :longitude, presence: true,
                        numericality: { greater_than_or_equal_to: -180,
                                        less_than_or_equal_to: 180 }
  # callbacks
  # other
  # class methods
  # instance methods
  include Rails.application.routes.url_helpers

  def place_data z
    { 
      name: "#{site_name} (#{location.description})", 
      lat: latitude,
      lon: longitude, 
      z: z.try(:to_i) || publications.count,
      url: site_path(id)
    }
  end
end
