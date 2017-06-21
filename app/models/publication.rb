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
#

class Publication < ActiveRecord::Base
  #self.inheritance_column = :_type_disabled # TODO: TEMPORARY FIX

  # constants
  PUBLICATION_TYPES = ['scientific', 'technical', 'popular'].freeze
  PUBLICATION_FORMATS = ['article', 'review', 'report', 'thesis', 
                       'book', 'chapter'].freeze
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

  # class methods
  def self.search(search)
    where("title LIKE ? OR contents LIKE ? OR abstract LIKE ?", 
          "%#{search}%", "%#{search}%", "%#{search}%")
  end



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

  # instance methods
  def create_journal_from_name
    create_journal(name: new_journal_name) unless new_journal_name.blank?
  end

  def generate_filename_from_doi
    DOI.sub('/', '___')
  end

  def occurrence_in_contents(search_term)
    if !contents.nil?
      return contents.downcase.scan(/#{search_term.downcase}/).count
    else
      return 0
    end
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
    photos.count >= 6
  end
end
