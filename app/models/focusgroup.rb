# == Schema Information
#
# Table name: focusgroups
#
#  id          :integer          not null, primary key
#  description :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Focusgroup < ActiveRecord::Base
  # constants
  # attributes
  # associations
  has_and_belongs_to_many :publications, touch: true
  has_and_belongs_to_many :expeditions, touch: true

  # validations
  validates :description, presence: true

  # callbacks
  # other
  # class methods
  # instance methods
end
