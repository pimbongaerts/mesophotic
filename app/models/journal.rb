# == Schema Information
#
# Table name: journals
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  open_access :boolean
#

class Journal < ApplicationRecord
  # constants
  # attributes

  # associations
  has_many :publications

  # validations
  validates :name, presence: true

  # callbacks
  # other
  # class methods
  # instance methods
end
