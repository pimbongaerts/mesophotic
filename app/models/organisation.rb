# == Schema Information
#
# Table name: organisations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  country    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Organisation < ApplicationRecord
  # constants
  # attributes
  # associations
  has_many :users
  has_and_belongs_to_many :expeditions
  has_and_belongs_to_many :meetings
  has_and_belongs_to_many :photos

  # validations
  validates :name, presence: true
  validates :country, presence: true

  # callbacks
  # other
  # class methods
  # instance methods
end
