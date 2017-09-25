# == Schema Information
#
# Table name: posts
#
#  id                      :integer          not null, primary key
#  title                   :string(255)
#  content_md              :text(65535)
#  content_html            :text(65535)
#  draft                   :boolean          default(FALSE)
#  user_id                 :integer
#  slug                    :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  postable_id             :integer
#  postable_type           :string
#  post_type               :string
#  featured_user_id        :integer
#  featured_publication_id :integer
#

class Post < ActiveRecord::Base
  # constants
  POST_TYPES = ['behind_the_science', 'early_career', 'method_feature'].freeze

  # attributes

  # associations
  belongs_to :postable, polymorphic: true
  belongs_to :user, touch: true
  belongs_to :featured_user, class_name: 'User', foreign_key: 'featured_user_id'
  belongs_to :featured_publication, class_name: 'Publication', foreign_key: 'featured_publication_id'
  has_many :photos

  # validations
  validates :post_type, presence: true
  validates :user_id, presence: true
  validates :featured_publication_id, presence: true, 
            :if => lambda { self.post_type == 'behind_the_science'}
  validates :featured_user_id, presence: true, 
            :if => lambda { self.post_type == 'early_career'}
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
