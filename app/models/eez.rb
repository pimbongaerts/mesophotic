# == Schema Information
#
# Table name: eezs
#
#  id         :integer          not null, primary key
#  mrgid      :integer          not null
#  geoname    :string           not null
#  sovereign  :string           not null
#  territory  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Eez < ApplicationRecord
  has_many :locations
  has_many :publications, -> { distinct }, through: :locations

  validates :mrgid, presence: true, uniqueness: true
  validates :geoname, presence: true
  validates :sovereign, presence: true
  validates :territory, presence: true

  scope :by_sovereign, ->(name) { where(sovereign: name) }
  scope :with_publications, -> {
    joins(locations: :publications).distinct
  }

  def self.sovereigns
    distinct.pluck(:sovereign).sort
  end
end
