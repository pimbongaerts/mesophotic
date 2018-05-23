# == Schema Information
#
# Table name: species
#
#  id                :integer          not null, primary key
#  name              :string
#  focusgroup_id     :integer
#  fishbase_webid    :string
#  aims_webid        :string
#  coraltraits_webid :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Species < ApplicationRecord
  # constants
  # attributes

  # associations
  belongs_to :focusgroup
  has_many :observations
  has_and_belongs_to_many :publications

  # validations
  # callbacks
  after_create :speciate
  after_update :speciate
  after_destroy :speciate

  # other
  # class methods
  # instance methods
  def img_url
    if aims_webid
      "http://coral.aims.gov.au/factsheet.jsp?speciesCode=#{aims_webid}"
    elsif fishbase_webid
      "http://www.fishbase.org/summary/#{fishbase_webid}"
    end
  end

  def publications
    Publication.relevance(name)
  end

  def description
    name
  end

  def short_description
    "#{name};#{abbreviation}"
  end

  def abbreviation
    parts = name.split(/\s+/)
    "#{parts[0][1]} #{parts[1]}"
  end

  def speciate species
    SpeciationJob.perform_later species
  end
end
