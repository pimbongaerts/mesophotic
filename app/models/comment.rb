# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  commentable_id   :integer
#  commentable_type :string
#  user_id          :integer
#  content          :string
#  internal         :boolean
#  request          :boolean
#  request_handled  :boolean
#  request_response :string
#

class Comment < ActiveRecord::Base
  # constants
  # attributes
  
  # associations
  belongs_to :commentable, polymorphic: true

  # validations
  validates :content, presence: true
  validates :user_id, presence: true

  # callbacks
  # other
  # class methods
  # instance methods
end
