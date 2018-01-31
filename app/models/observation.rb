# == Schema Information
#
# Table name: observations
#
#  id              :integer          not null, primary key
#  observable_id   :integer
#  observable_type :string
#  species_id      :integer
#  location_id     :integer
#  site_id         :integer
#  user_id         :integer
#  depth           :integer
#  created_at      :datetime
#  updated_at      :datetime
#  depth_estimate  :boolean
#

class Observation < ApplicationRecord
  # constants
  # attributes
  # associations
  belongs_to :observable, polymorphic: true
  belongs_to :species
  belongs_to :location
  belongs_to :site
  belongs_to :user

  # validations
  validates :species_id , presence: true
  validates :user_id , presence: true
  validates :location_id, presence: true
  validates :depth, presence: true

  # callbacks
  # other
  # class methods
  # instance methods
end
