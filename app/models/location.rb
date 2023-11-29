# == Schema Information
#
# Table name: locations
#
#  id                :integer          not null, primary key
#  description       :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  latitude          :decimal(15, 10)  default(0.0)
#  longitude         :decimal(15, 10)  default(0.0)
#  short_description :text
#

class Location < ApplicationRecord
  # constants
  # attributes

  # associations
  has_and_belongs_to_many :publications, touch: true
  has_and_belongs_to_many :expeditions, touch: true
  has_many :sites # TODO: CHECK
  has_many :photos
  belongs_to :eez

  # validations
  validates :description, presence: true
  validates :latitude , presence: true,
                        numericality: { greater_than_or_equal_to:  -90,
                                        less_than_or_equal_to:  90 }
  validates :longitude, presence: true,
                        numericality: { greater_than_or_equal_to: -180,
                                        less_than_or_equal_to: 180 }

  # callbacks

  # other

  scope :published, -> {
    joins(:publications)
    .group('locations.id')
    .order('count(locations.id) DESC')
  }

  # class methods
  # instance methods
  include Rails.application.routes.url_helpers

  def place_data z
    {
      name: description,
      lat: latitude.to_f,
      lon: longitude.to_f,
      z: z.try(:to_i) || publications.validated.length,
      url: location_path(id)
    }
  end

  def chart_description
    short_description.present? && short_description.include?(";") ? description : short_description
  end

  def chart_data
  end
end
