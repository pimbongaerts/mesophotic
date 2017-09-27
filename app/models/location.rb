# == Schema Information
#
# Table name: locations
#
#  id          :integer          not null, primary key
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  latitude    :decimal(15, 10)  default(0.0)
#  longitude   :decimal(15, 10)  default(0.0)
#

class Location < ActiveRecord::Base
  # constants
  # attributes

  # associations
  has_and_belongs_to_many :publications, touch: true
  has_and_belongs_to_many :expeditions, touch: true
  has_many :sites # TODO: CHECK
  has_many :photos

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
  # class methods
  # instance methods
end
