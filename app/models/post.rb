# == Schema Information
#
# Table name: posts
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  content_md    :text(65535)
#  content_html  :text(65535)
#  draft         :boolean          default(FALSE)
#  user_id       :integer
#  slug          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  postable_id   :integer
#  postable_type :string
#

class Post < ActiveRecord::Base
  # constants
  # attributes

  # associations
  belongs_to :postable, polymorphic: true
  belongs_to :user, touch: true
  has_many :photos

  # validations
  validates :title, presence: true, length: { maximum: 100 }, uniqueness: true
  validates :content_md, presence: true

  # callbacks
  before_save { MarkdownWriter.update_html(self) }

  # other
  extend FriendlyId
  friendly_id :title, use: :slugged
  paginates_per 30

  # scopes
  scope :published, lambda {
    where(draft: false)
      .order('updated_at DESC')
  }

  scope :drafted, lambda {
    where(draft: true)
      .order('updated_at DESC')
  }

  # class methods
  # instance methods
end
