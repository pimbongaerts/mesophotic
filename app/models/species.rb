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

class Species < ActiveRecord::Base
  # constants
  # attributes

  # associations
  belongs_to :focusgroup
  has_many :observations

  # validations
  # callbacks
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
end
