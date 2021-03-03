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
  
  # class methods

  scope :names, -> () {
    names = select("GROUP_CONCAT(LOWER(TRIM(name)), ' ') AS names").first.names
    
    ActiveRecord::Base.connection.execute("
      WITH RECURSIVE split(content, last, rest) AS (
        VALUES('', '', \"#{names}\")
        UNION ALL
        SELECT 
          CASE 
          WHEN last = ' ' 
            THEN substr(rest, 1, 1)
          ELSE content || substr(rest, 1, 1)
          END,
          substr(rest, 1, 1),
          substr(rest, 2)
        FROM split
        WHERE rest IS NOT ''
      )

      SELECT DISTINCT REPLACE(content, ' ', '') AS name
      FROM split
      WHERE (last = ' ' OR rest = '')
      AND LENGTH(name) > 0
      ORDER BY name ASC
    ")
    .each_with_object(Set.new) { |n, memo|
      memo << n["name"]
    }
  }

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

  def speciate
    SpeciationJob.perform_now(Species.where(id: id), Publication.all)
  end
end
