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
  # other
  # class methods
  # instance methods
  def species_code
    name.parameterize(separator: '-')
  end

  def img_url
    if focusgroup_id == 1 # Fish
      "http://www.fishbase.org/summary/#{species_code}"
    elsif focusgroup_id == 2 # Coral
      "http://www.coralsoftheworld.org/species_factsheets/species_factsheet_summary/#{species_code}/"
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
    "#{parts[0][0]}\.? #{parts[1]}"
  end
end
