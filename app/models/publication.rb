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
#  external_id        :text
#  contributor_id     :integer
#

class Publication < ApplicationRecord
  #self.inheritance_column = :_type_disabled # TODO: TEMPORARY FIX

  # constants
  PUBLICATION_TYPES = ['scientific', 'technical', 'popular'].freeze
  PUBLICATION_FORMATS = ['article', 'review', 'report', 'thesis', 'book', 'chapter'].freeze
  PUBLICATION_SEARCH_FIELDS = ['title', 'abstract', 'contents', 'authors', 'doi'].freeze
  PUBLICATION_CHARACTERISTICS = Publication.columns.select { |c| c.sql_type =~ /^boolean/ }.map(&:name).sort.freeze
  PUBLICATION_LOCATIONS = Location.select(:description).order(:description).map(&:description).uniq.freeze
  PUBLICATION_FOCUSGROUPS = Focusgroup.select(:description).order(:description).map(&:description).uniq.freeze
  PUBLICATION_PLATFORMS = Platform.select(:description).order(:description).map(&:description).uniq.freeze
  PUBLICATION_FIELDS = Field.select(:description).order(:description).map(&:description).uniq.freeze
  WORDCLOUD_FREQLIMIT = 50.freeze

  # attributes
  attr_accessor :new_journal_name

  # associations
  belongs_to :journal, optional: true
  has_and_belongs_to_many :users
  has_and_belongs_to_many :platforms
  has_and_belongs_to_many :fields
  has_and_belongs_to_many :focusgroups
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :sites
  has_and_belongs_to_many :species
  has_many :validations, as: :validatable
  has_many :user_validations, through: :validations, source: :user
  has_many :observations, as: :observable
  has_many :photos
  has_one :featured_post, class_name: 'Post', primary_key: 'id', foreign_key: 'featured_publication_id'
  belongs_to :contributor, class_name: 'User'
  has_one_attached :pdf

  paginates_per 20

  # validations
  validates :title, presence: true
  validates :authors, presence: true
  validates :publication_year, presence: true
  validates :pdf, content_type: 'application/pdf'

  # callbacks
  before_save :create_journal_from_name

  # other
  scope :validated, -> {
    select("publications.*, COUNT(validations.id) AS validations_count")
    .joins("LEFT JOIN validations
      ON validations.validatable_id = publications.id
      AND validations.updated_at >= publications.updated_at")
    .group("publications.id")
    .having("validations_count >= 2")
  }

  scope :unvalidated, -> {
    select("publications.*, COUNT(validations.id) AS validations_count")
    .joins("LEFT JOIN validations
      ON validations.validatable_id = publications.id
      AND validations.updated_at >= publications.updated_at")
    .group("publications.id")
    .having("validations_count < 2")
  }

  scope :expired, -> (user) {
    select("publications.*, COUNT(validations.id) AS validations_count")
    .joins(:validations)
    .where("validations.user_id = ? AND validations.updated_at < publications.updated_at", user.id)
    .group("publications.id") if user.present?
  }

  scope :search, -> (search_term, search_params = Publication.default_search_params, is_editor_or_admin = false) {
    case [search_term.present?, is_editor_or_admin]
    when [true, true] then sift(search_term, search_params)
    when [true, false] then relevance(search_term, search_params)
    else base_search(search_params).order(id: :asc)
    end
  }

  scope :base_search, -> (search_params = Publication.default_search_params) {
    min_depth, max_depth = *(search_params["depth_range"] || "0,500").split(",").map(&:to_i)
    min_year, max_year = *(search_params["year_range"] || "#{Publication.min_year},#{Publication.max_year}").split(",").map(&:to_i)
    locations(search_params["locations"])
    .focusgroups(search_params["focusgroups"])
    .platforms(search_params["platforms"])
    .fields(search_params["fields"])
    .where("publication_type IN (?) OR publication_type IS NULL", search_params["types"])
    .where("publication_format IN (?) OR publication_format IS NULL", search_params["formats"])
    .where((search_params["characteristics"] || []).map { |c| "#{c} = 1" }.join(" OR "))
    .where("(min_depth IS NULL OR min_depth <= ?) AND (max_depth IS NULL OR max_depth >= ?)", max_depth >= 500 ? Publication.max_depth : max_depth, min_depth)
    .where("(publication_year <= ?) AND (publication_year >= ?)", max_year, min_year)
  }

  [:location, :focusgroup, :platform, :field].each do |name|
    scope "#{name}s", -> (params) {
      if params.present?
        joins("INNER JOIN #{name}s_publications ON publications.id = #{name}s_publications.publication_id")
        .joins("INNER JOIN #{name}s ON #{name}s.id = #{name}s_publications.#{name}_id")
        .where("#{name}s.description IN (?)", params)
      end
    }
  end

  scope :sift, -> (search_term, search_params = Publication.default_search_params) {
    if search_term.present?
      fields = search_params["search_fields"] || []
      clause = fields.map { |field| "LOWER(#{field}) LIKE ?"}.join(" OR ")
      terms = Array.new(fields.count, "%#{search_term.downcase}%")
      where(clause, *terms)
      .base_search(search_params)
      .order("publication_year DESC")
    end
  }

  scope :relevance, -> (search_term, search_params = Publication.default_search_params) {
    if search_term.present?
      st = ActiveRecord::Base.sanitize_sql_for_conditions ["?", search_term]

      filter = (search_params["search_fields"] || PUBLICATION_SEARCH_FIELDS).map { |field|
        "(IFNULL(LENGTH(#{field}), 0) - IFNULL(LENGTH(REPLACE(LOWER(#{field}), LOWER(#{st}), '')), 0))"
      }.join(" + ")

      records = select("*, (#{filter}) / LENGTH(#{st}) AS relevance")
      limited = records.where("relevance > 0")
      records
      .where("publications.id IN (SELECT id FROM (#{limited.to_sql}))")
      .base_search(search_params)
      .order("relevance DESC, publication_year DESC, filename ASC")
    end
  }

  def self.should_show_relevance fields
    fields.include? "contents" or fields.include? "abstract"
  end

  def relevance_content fields
    if fields.include? "contents"
      contents
    elsif fields.include? "abstract"
      abstract
    else
      nil
    end
  end

  scope :original, -> () {
    where(original_data: true)
  }

  scope :statistics, -> (status, year) {
    case status
      when :all
        all
      when :validated
        validated
    end
    .original
    .where(mesophotic: true)
    .where(publication_format: 'article')
    .where(publication_type: 'scientific')
    .where('publication_year <= ?', year)
    .order('publication_year DESC, created_at DESC')
  }

  scope :latest, -> (count) {
    order('publication_year DESC, created_at DESC')
    .limit(count)
  }

  scope :annual_counts, -> () {
    # all.reduce({}) { |accum, p| accum[p.publication_year] = (accum[p.publication_year] || 0) + 1; accum }
    find_by_sql("
      SELECT publication_year AS year, COUNT(id) AS count
      FROM (#{self.to_sql})
      GROUP BY year
      ORDER BY year
      ")
    .reduce({}) { |a, r| a[r.year] = r.count; a }
  }

  scope :key, -> () {
    select("GROUP_CONCAT(publications.id, ',')")
  }

  scope :word_cloud, -> (size) {
    everything = select("GROUP_CONCAT(contents, ' ') AS everything").first.everything
    WordCloud.generate size, everything
  }

  def word_cloud size
    WordCloud.generate size, contents
  end

  # class methods
  scope :csv, -> (options = {}) {
    CSV.generate(options) do |csv|
      csv << csv_header

      validated = Publication.validated.map(&:id)
      fields = Field
        .select("publications.id, GROUP_CONCAT(description, '; ') AS description")
        .joins(:publications)
        .group("publications.id")
        .reduce({}) { |result, a| result.update(a.id => a.description) }
      focusgroups = Focusgroup
        .select("publications.id, GROUP_CONCAT(description, '; ') AS description")
        .joins(:publications)
        .group("publications.id")
        .reduce({}) { |result, a| result.update(a.id => a.description) }
      platforms = Platform
        .select("publications.id, GROUP_CONCAT(description, '; ') AS description")
        .joins(:publications)
        .group("publications.id")
        .reduce({}) { |result, a| result.update(a.id => a.description) }
      locations = Location
        .select("publications.id, GROUP_CONCAT(description, '; ') AS description")
        .joins(:publications)
        .group("publications.id")
        .reduce({}) { |result, a| result.update(a.id => a.description) }

      for publication in csv_rows
        csv << csv_row(publication, validated, fields, focusgroups, platforms, locations)
      end
    end
  }

  scope :csv_rows, -> {
    select(
      """
      publications.id,

      publications.publication_type,
      publications.publication_format,
      publications.publication_year,
      publications.authors,
      publications.title,
      journals.name AS journal_name,
      publications.volume,
      publications.issue,
      publications.pages,
      publications.DOI,
      publications.url,
      publications.book_title,
      publications.book_authors,
      publications.book_publisher,
      active_storage_attachments.id AS pdf_id,
      publications.mesophotic,
      publications.mce,
      publications.tme,
      publications.original_data,
      publications.new_species,
      publications.min_depth,
      publications.max_depth
      """
    )
    .left_joins(:journal, :pdf_attachment)
  }

  def self.csv_header
    [
      "id",
      "validated",
      "included_in_stats",
      "publication_type",
      "publication_format",
      "publication_year",
      "authors",
      "title",
      "journal_name",
      "volume",
      "issue",
      "pages",
      "doi",
      "url",
      "book_title",
      "book_authors",
      "book_publisher",
      "pdf_present",
      "mesophotic",
      "mce",
      "tme",
      "original_data",
      "new_species",
      "min_depth",
      "max_depth",
      "fields",
      "focusgroups",
      "platforms",
      "locations"
    ]
  end

  def self.csv_row publication, validated, fields, focusgroups, platforms, locations
    isValidated = validated.include?(publication.id)

    [
      publication.id,
      isValidated,
      publication.included_in_stats?(isValidated),
      publication.publication_type,
      publication.publication_format,
      publication.publication_year,
      publication.authors,
      publication.title,
      publication.journal_name,
      publication.volume,
      publication.issue,
      publication.pages,
      publication.DOI,
      publication.url,
      publication.book_title,
      publication.book_authors,
      publication.book_publisher,
      publication.pdf_id.present?,
      publication.mesophotic,
      publication.mce,
      publication.tme,
      publication.original_data,
      publication.new_species,
      publication.min_depth,
      publication.max_depth,
      fields[publication.id],
      focusgroups[publication.id],
      platforms[publication.id],
      locations[publication.id],
    ]
  end

  def self.default_search_params
    {
      "search_fields" => PUBLICATION_SEARCH_FIELDS,
      "depth_range" => "0,500",
      "year_range" => "#{min_year},#{max_year}",
      "types" => PUBLICATION_TYPES,
      "formats" => PUBLICATION_FORMATS,
      # "characteristics" => [],
      # "locations" => [],
      # "focusgroups" => [],
      # "platforms" => [],
      # "fields" => [],
    }
  end

  def self.should_show_advanced params
    [
      "depth_range",
      "year_range",
      "types",
      "formats",
      "characteristics",
      "locations",
      "focusgroups",
      "platforms",
      "fields"
    ].reduce(false) { |result, field|
      result || (default_search_params[field] != params[field])
    }
  end

  def self.max_depth
    reorder(max_depth: :desc).first.try(:max_depth) || 500
  end

  def self.min_depth
    reorder(min_depth: :asc).first.try(:min_depth) || 0
  end

  def self.max_year
    reorder(publication_year: :desc).first.publication_year
  end

  def self.min_year
    reorder(publication_year: :asc).first.publication_year
  end

  def self.authors
    joins(:users)
    .select("users.id as id, users.first_name as first_name, users.last_name as last_name, count(users.id) as count")
    .group("users.id")
    .order("count DESC")
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
    "https://doi.org/#{self.DOI}"
  end

  def scholar_url
    "http://scholar.google.com/scholar?q=#{self.DOI}"
  end

  def short_citation
    author_list = authors.split(",")
    first_author_full = author_list[0]
    first_author = first_author_full.split()[0..first_author_full.split().length-2].join(" ")
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

  def validated?
    Publication.validated.include?(self)
  end

  def included_in_stats? validated
    validated &&
    original_data &&
    mesophotic &&
    publication_type == "scientific" &&
    publication_format == "article"
  end

  def species_relevance object
    desc = Publication.where(id: id).relevance(object.name).first.try(:relevance) || 0
    sdesc = Publication.where(id: id).relevance(object.abbreviation).first.try(:relevance) || 0
    desc + sdesc
  end
end
