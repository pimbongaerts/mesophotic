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

class Post < ApplicationRecord
  # constants
  POST_TYPES = ['behind_the_science', 'early_career', 'method_feature', 'announcement'].freeze

  # attributes

  # associations
  belongs_to :postable, polymorphic: true, optional: true
  belongs_to :user, touch: true
  belongs_to :featured_user, class_name: 'User', foreign_key: 'featured_user_id'
  belongs_to :featured_publication, class_name: 'Publication', foreign_key: 'featured_publication_id', optional: true
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
  before_save {
    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,
      no_styles: true,
      no_images: false,
      with_toc_data: false,
      link_attributes: {:target => "_blank"}
    )

    converter = Redcarpet::Markdown.new(renderer)
    self.content_html = converter.render(self.content_md)
  }

  # other
  extend FriendlyId
  friendly_id :title, use: :slugged
  paginates_per 30

  # scopes
  scope :published, -> {
    where(draft: false)
      .order('created_at DESC')
  }

  scope :latest, -> (count) {
    published.limit(count)
  }

  scope :drafted, -> {
    where(draft: true)
      .order('created_at DESC')
  }

  # class methods
  # instance methods
  def category
    if post_type == 'behind_the_science'
      "Behind the science"
    elsif post_type == 'early_career'
      "Early Career Scientist"
    elsif post_type == 'method_feature'
      "Methods Exposed"
    elsif post_type == 'announcement'
      "Announcement"
    end
  end
end
