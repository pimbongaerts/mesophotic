# == Schema Information
#
# Table name: platforms
#
#  id                :integer          not null, primary key
#  description       :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  short_description :text
#

class Platform < ApplicationRecord
  # constants
  # attributes

  # associations
  has_and_belongs_to_many :users, touch: true
  has_and_belongs_to_many :publications, touch: true
  has_and_belongs_to_many :expeditions, touch: true
  has_and_belongs_to_many :photos

  # validations
  validates :description, presence: true

  # callbacks
  # other
  # class methods
  # instance methods
end
