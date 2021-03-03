# == Schema Information
#
# Table name: word_exclusions
#
#  id         :integer          not null, primary key
#  word       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WordExclusion < ApplicationRecord
  # constants
  # attributes
  # associations
  # validations
  # callbacks
  # other
  # class methods

  scope :list, -> () {
    select("LOWER(word) AS word")
    .flat_map { |w| ["'#{w.word.singularize}'", "'#{w.word.pluralize}'"] }
    .to_set
    .to_a
    .join(", ")
  }

  # instance methods
end
