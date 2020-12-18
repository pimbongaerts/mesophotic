# == Schema Information
#
# Table name: presentations
#
#  id               :integer          not null, primary key
#  title            :string
#  abstract         :text
#  authors          :text
#  oral             :boolean
#  session          :string
#  date             :string
#  time             :string
#  location         :string
#  poster_id        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  meeting_id       :integer
#  pdf_file_name    :string
#  pdf_content_type :string
#  pdf_file_size    :integer
#  pdf_updated_at   :datetime
#

class Presentation < ApplicationRecord
  # constants
  # attributes

  # associations
  belongs_to :meeting
  has_and_belongs_to_many :users
  has_one_attached :pdf

  # validations
  validates :title, presence: true
  validates :abstract, presence: true
  validates :authors, presence: true
  validates :date, presence: true
  validates :meeting_id, presence: true
  validates :pdf, content_type: 'application/pdf'

  # callbacks
  # other
  # class methods
  # instance methods
end
