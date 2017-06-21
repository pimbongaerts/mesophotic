# == Schema Information
#
# Table name: species
#
#  id              :integer          not null, primary key
#  name            :string
#  focusgroup_id   :integer
#  url_fishbase    :string
#  url_aims        :string
#  url_coraltraits :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Species < ActiveRecord::Base
  # constants
  # attributes

  # associations
  has_many :observations

  # validations
  # callbacks
  # other
  # class methods
  # instance methods
end
