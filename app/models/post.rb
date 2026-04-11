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
  belongs_to :featured_user, class_name: 'User', foreign_key: 'featured_user_id', optional: true
  belongs_to :featured_publication, class_name: 'Publication', foreign_key: 'featured_publication_id', optional: true
  has_many :photos

  # validations
  validates :post_type, presence: true
  validates :user_id, presence: true
  validates :featured_publication_id, presence: true,
            :if => lambda { post_type.in?(%w[behind_the_science method_feature]) }
  validates :featured_user_id, presence: true,
            :if => lambda { post_type.in?(%w[early_career method_feature]) }
  validates :title, presence: true, length: { maximum: 100 }, uniqueness: true
  validates :content_md, presence: true

  # callbacks
  before_save :normalise_line_endings
  before_save :render_markdown

  def normalise_line_endings
    return unless content_md.present?
    self.content_md = content_md.gsub("\r\n", "\n").gsub("\r", "\n")
  end

  def render_markdown
    renderer = Redcarpet::Render::HTML.new(
      filter_html: false,
      no_styles: true,
      no_images: false,
      with_toc_data: false,
      link_attributes: {:target => "_blank"}
    )

    converter = Redcarpet::Markdown.new(renderer)
    self.content_html = converter.render(self.content_md)
  end

  # other
  extend FriendlyId
  friendly_id :title, use: :slugged
  paginates_per 30

  # scopes
  scope :published, -> {
    where(draft: false)
      .order(created_at: :desc)
  }

  scope :latest, -> (count) {
    published.limit(count)
  }

  scope :drafted, -> {
    where(draft: true)
      .order(created_at: :desc)
  }

  def word_cloud size
    WordCloud.generate size, content_md
  end

  # class methods
  # instance methods
  def category
    case post_type
    when 'behind_the_science' then "Behind the Science"
    when 'early_career' then "Early Career Scientist"
    when 'method_feature' then "Methods Exposed"
    when 'announcement' then "Announcement"
    end
  end

  # Parse content_md into an ordered array of content blocks.
  # Sections starting with ##### are "quick questions" — grouped consecutively.
  # Everything else is a normal section that gets paired with photos.
  def parsed_content
    return [] unless content_md.present?

    raw_sections = content_md.split("\n\n").reject(&:blank?)
    blocks = []

    raw_sections.each do |section|
      if section.start_with?("#####")
        if blocks.last && blocks.last[:type] == :quick_question_group
          blocks.last[:questions] << section
        else
          blocks << { type: :quick_question_group, questions: [section] }
        end
      else
        blocks << { type: :section, content: section }
      end
    end

    blocks
  end
end
