# == Schema Information
#
# Table name: publications
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  authors            :text(65535)
#  publication_year   :integer
#  title              :string(255)
#  journal_id         :integer
#  issue              :string(255)
#  pages              :string(255)
#  DOI                :string(255)
#  url                :string(255)
#  book_title         :string(255)
#  book_publisher     :string(255)
#  abstract           :text(65535)
#  contents           :text(65535)
#  volume             :string(255)
#  min_depth          :integer
#  max_depth          :integer
#  new_species        :boolean
#  filename           :string(255)
#  original_data      :boolean
#  mesophotic         :boolean
#  pdf_file_name      :string
#  pdf_content_type   :string
#  pdf_file_size      :integer
#  pdf_updated_at     :datetime
#  book_authors       :string
#  publication_type   :string
#  mce                :boolean          default(TRUE)
#  publication_format :string           default("article")
#  behind_contents    :text
#

class Publication < ActiveRecord::Base
  #self.inheritance_column = :_type_disabled # TODO: TEMPORARY FIX

  # constants
  PUBLICATION_TYPES = ['scientific', 'technical', 'popular'].freeze
  PUBLICATION_FORMATS = ['article', 'review', 'report', 'thesis', 'book', 'chapter'].freeze
  PUBLICATION_SEARCH_FIELDS = ["title", "abstract", "contents", "authors"].freeze
  PUBLICATION_CHARACTERISTICS = Publication.columns.select { |c| c.sql_type =~ /^boolean/ }.map(&:name).sort.freeze
  WORDCLOUD_FREQLIMIT = 50.freeze

  # attributes
  attr_accessor :new_journal_name

  # associations
  belongs_to :journal
  has_and_belongs_to_many :users
  has_and_belongs_to_many :platforms
  has_and_belongs_to_many :fields
  has_and_belongs_to_many :focusgroups
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :sites
  has_many :validations, as: :validatable
  has_many :user_validations, through: :validations, source: :user
  has_many :observations, as: :observable
  has_many :photos
  has_one :featured_post, class_name: 'Post', primary_key: 'id', foreign_key: 'featured_publication_id'
  has_attached_file :pdf,
                    styles: { medium: ['450x640>', :png],
                              thumb: ['100x140>', :png] },
                    default_url: 'no_pdf.png'

  # validations
  validates :title, presence: true
  validates :authors, presence: true
  validates :publication_year, presence: true
  validates_attachment :pdf, content_type: { content_type: 'application/pdf' }

  # callbacks
  before_save :create_journal_from_name

  # other
  scope :validated, -> {
    select("publications.*, COUNT(validations.id) AS validations_count")
    .joins(:validations)
    .where("validations.updated_at >= publications.updated_at")
    .group("publications.id")
    .having("validations_count >= 3")
  }

  scope :unvalidated, -> {
    select("publications.*, COUNT(validations.id) AS validations_count")
    .joins("LEFT JOIN validations
            ON validations.validatable_id = publications.id
            AND validations.updated_at >= publications.updated_at")
    .group("publications.id")
    .having("validations_count < 3")
  }

  scope :expired, -> (user) {
    select("publications.*, COUNT(validations.id) AS validations_count")
    .joins(:validations)
    .where("validations.user_id = ? AND validations.updated_at < publications.updated_at", user.id)
    .group("publications.id") if user.present?
  }

  scope :search, -> (search_term, search_params = default_search_params, is_editor_or_admin = false) {
    case [search_term.present?, is_editor_or_admin]
    when [true, true] then filter(search_term, search_params)
    when [true, false] then relevance(search_term, search_params)
    else base_search(search_params).order(id: :asc)
    end
  }

  scope :base_search, -> (search_params = default_search_params) {
    where("publication_type IN (?) OR publication_type IS NULL", search_params[:publication_types])
    .where("publication_format IN (?) OR publication_format IS NULL", search_params[:publication_formats])
    .where((search_params[:characteristics] || []).map { |c| "#{c} = 't'" }.join(" OR "))
  }

  scope :filter, -> (search_term, search_params = default_search_params) {
    if search_term.present?
      clause = search_params[:fields].map { |field| "#{field} LIKE ?"}.join(" OR ")
      terms = Array.new(search_params[:fields].count, "%#{search_term}%")
      where(clause, *terms)
      .base_search(search_params)
    end
  }

  scope :relevance, -> (search_term, search_params = default_search_params) {
    if search_term.present?
      filter = search_params[:fields].map { |field|
      "(IFNULL(LENGTH(#{field}), 0) - IFNULL(LENGTH(REPLACE(LOWER(#{field}), LOWER('#{search_term}'), '')), 0))"
    }.join(" + ")

      relevance = select("*, (#{filter}) / LENGTH('#{search_term}') AS relevance")
      limited = relevance.where("relevance > 0")
      relevance
      .where("id IN (SELECT id FROM (#{limited.to_sql}))")
      .base_search(search_params)
      .order("relevance DESC, filename ASC")
    end
  }

  # class methods
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["id", "publication_type", "publication_format",
              "publication_year", "authors", "title",
              "journal_name", "volume", "issue", "pages", "doi", "url",
              "book_title", "book_authors", "book_publisher", "pdf_present",
              " ", "mesophotic", "coralreef", "original_data", "new_species",
              "min_depth", "max_depth", " ", "fields", "focusgroups",
              "platforms", "locations"]
      all.each do |publication|
        csv_line = [publication.id,
                    publication.publication_type,
                    publication.publication_format,
                    publication.publication_year,
                    publication.authors,
                    publication.title,
                    publication.journal ? publication.journal.name : " ",
                    publication.volume,
                    publication.issue,
                    publication.pages,
                    publication.DOI,
                    publication.url,
                    publication.book_title,
                    publication.book_authors,
                    publication.book_publisher,
                    publication.pdf.exists?,
                    " ",
                    publication.mesophotic,
                    publication.mce,
                    publication.original_data,
                    publication.new_species,
                    publication.min_depth,
                    publication.max_depth,
                    " ",
                    publication.fields.map(&:description).join("; "),
                    publication.focusgroups.map(&:description).join("; "),
                    publication.platforms.map(&:description).join("; "),
                    publication.locations.map(&:description).join("; ")]
        csv << csv_line
      end
    end
  end

  def self.default_search_params
    {
      fields: PUBLICATION_SEARCH_FIELDS,
      publication_types: PUBLICATION_TYPES,
      publication_formats: PUBLICATION_FORMATS,
      characteristics: []
    }
  end

  # instance methods
  def create_journal_from_name
    create_journal(name: new_journal_name) unless new_journal_name.blank?
  end

  def generate_filename_from_doi
    DOI.sub('/', '___')
  end

  def title_truncated
    title.truncate(70)
  end

  def open_access?
    journal && journal.open_access?
  end

  def scientific_article?
    (publication_type == "scientific") &&
    (['article', 'review'].include? publication_format)
  end

  def chapter?
    publication_format == "chapter"
  end

  def doi_url
    "http://dx.doi.org/#{self.DOI}"
  end

  def scholar_url
    "http://scholar.google.com/scholar?q=#{self.DOI}"
  end

  def short_citation
    author_list = authors.split(",")
    first_author = author_list[0].split()[0]
    if authors.count(",") == 0
      "#{first_author} #{publication_year}"
    elsif authors.count(",") == 1
      second_author = author_list[1].split()[0]
      "#{first_author} and #{second_author} #{publication_year}"
    else
      "#{first_author} et al. #{publication_year}"
    end
  end

  def short_citation_with_title
    "#{short_citation} #{title.truncate(20)}"
  end

  def behind_the_science?
    featured_post && featured_post.post_type == 'behind_the_science'
  end
end
