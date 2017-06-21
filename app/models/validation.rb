# == Schema Information
#
# Table name: validations
#
#  id               :integer          not null, primary key
#  validatable_id   :integer
#  validatable_type :string
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Validation < ActiveRecord::Base
  # constants
  VALIDATION_TYPES = ["all", "validated", "expired"].freeze # TODO: "unvalidated"
  
  # attributes

  # associations
  belongs_to :validatable, polymorphic: true
  belongs_to :user

  # validations
  validates :user_id, presence: true
  validates :validatable_type, presence: true
  validates :validatable_id, presence: true

  # callbacks
  # other
  # class methods
  # instance methods
end