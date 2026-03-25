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
#

require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  test "search, find something" do
    assert_equal (Publication.sift "II"), (Publication.search "II", Publication.default_search_params, true)
    assert_equal (Publication.relevance "II"), (Publication.search "II", Publication.default_search_params, false)
    assert_equal (Publication.relevance "II"), (Publication.search "II", Publication.default_search_params)
    assert_equal (Publication.relevance "II"), (Publication.search "II")
  end

  test "search, find nothing" do
    assert_equal [], (Publication.search "Fred Astaire", Publication.default_search_params, true)
    assert_equal [], (Publication.search "Ginger Rogers", Publication.default_search_params, false)
    assert_equal [], (Publication.search "James Dean", Publication.default_search_params)
    assert_equal [], (Publication.search "Marilyn Monroe")
  end

  test "empty search" do
    assert_equal Publication.all.order(:id).to_a, (Publication.search "", Publication.default_search_params, true).to_a
    assert_equal Publication.all.order(:id).to_a, (Publication.search "", Publication.default_search_params, false).to_a
    assert_equal Publication.all.order(:id).to_a, (Publication.search "", Publication.default_search_params).to_a
    assert_equal Publication.all.order(:id).to_a, (Publication.search "").to_a
  end

  test "search orders by id" do
    assert_equal Publication.all.order(:id).to_a, (Publication.search "").to_a
  end

  test "sift" do
    assert_equal [publications(:three), publications(:two)], (Publication.sift "II").to_a
  end

  test "sifted everything" do
    assert_equal [], (Publication.sift "Fred Astaire")
  end

  test "no sift" do
    assert_equal Publication.all, (Publication.sift "")
  end

  test "relevance" do
    assert_equal [publications(:three), publications(:two)], (Publication.relevance "II").to_a
  end

  test "relevance scores" do
    scores = (Publication.relevance "Led Zeppelin")
    assert_equal 2, scores.first.relevance
    assert_equal 1, scores.last.relevance
  end

  test "irrelevance" do
    assert_equal [], (Publication.relevance "Fred Astaire")
  end

  test "no relevance" do
    assert_equal Publication.all, (Publication.relevance "")
  end

  test "depth search, find everything" do
    assert_equal Publication.all.to_a, (Publication.search "", Publication.default_search_params).to_a
  end

  test "depth search, find three, one" do
    assert_equal [publications(:three), publications(:scientific_article), publications(:book_chapter), publications(:one)], (Publication.search "", Publication.default_search_params.merge("depth_range" => "40, 200")).to_a
  end

  test "depth search, find one" do
    assert_equal [publications(:book_chapter), publications(:one)], (Publication.search "", Publication.default_search_params.merge("depth_range" => "200, 300")).to_a
  end

  # -- Task 4: Validation and association tests --

  test "requires title" do
    pub = Publication.new(authors: "Author", publication_year: 2020, contributor: users(:admin_user))
    assert_not pub.valid?
    assert_includes pub.errors[:title], "can't be blank"
  end

  test "requires authors" do
    pub = Publication.new(title: "Title", publication_year: 2020, contributor: users(:admin_user))
    assert_not pub.valid?
    assert_includes pub.errors[:authors], "can't be blank"
  end

  test "requires publication_year" do
    pub = Publication.new(title: "Title", authors: "Author", contributor: users(:admin_user))
    assert_not pub.valid?
    assert_includes pub.errors[:publication_year], "can't be blank"
  end

  test "valid publication saves" do
    pub = Publication.new(
      title: "Valid Publication",
      authors: "Author A",
      publication_year: 2020,
      contributor: users(:admin_user)
    )
    assert pub.valid?
  end

  test "belongs to journal" do
    pub = publications(:scientific_article)
    assert_equal journals(:open_journal), pub.journal
  end

  test "journal is optional" do
    pub = publications(:one)
    assert_nil pub.journal
  end

  test "belongs to contributor" do
    pub = publications(:scientific_article)
    assert_equal users(:admin_user), pub.contributor
  end

  test "has and belongs to many users" do
    pub = publications(:scientific_article)
    pub.users << users(:regular_user)
    assert_includes pub.users, users(:regular_user)
  end

  test "has many validations" do
    pub = publications(:scientific_article)
    assert_equal 2, pub.validations.count
  end

  # -- Task 5: Instance method and callback tests --

  test "open_access? returns true when journal is open access" do
    pub = publications(:scientific_article)
    assert pub.open_access?
  end

  test "open_access? returns false when journal is not open access" do
    pub = publications(:book_chapter)
    assert_equal journals(:closed_journal), pub.journal
    assert_not pub.open_access?
  end

  test "open_access? returns false when no journal" do
    pub = publications(:one)
    assert_nil pub.journal
    assert_not pub.open_access?
  end

  test "scientific_article? for scientific article" do
    pub = publications(:scientific_article)
    assert pub.scientific_article?
  end

  test "scientific_article? false for chapter" do
    pub = publications(:book_chapter)
    assert_not pub.scientific_article?
  end

  test "chapter? for chapter format" do
    pub = publications(:book_chapter)
    assert pub.chapter?
  end

  test "chapter? false for article" do
    pub = publications(:scientific_article)
    assert_not pub.chapter?
  end

  test "doi_url returns formatted DOI link" do
    pub = publications(:scientific_article)
    assert_equal "https://doi.org/10.1234/meso.2020", pub.doi_url
  end

  test "scholar_url returns Google Scholar link with DOI" do
    pub = publications(:scientific_article)
    url = pub.scholar_url
    assert_match /scholar\.google\.com/, url
    assert_match /10\.1234/, url
  end

  test "short_citation formats authors and year" do
    pub = publications(:scientific_article)
    citation = pub.short_citation
    assert_match /Smith/, citation
    assert_match /2020/, citation
  end

  test "title_truncated truncates long titles" do
    pub = publications(:scientific_article)
    assert pub.title_truncated.length <= 73  # 70 + "..."
  end

  test "validated? returns true with 2+ validations" do
    pub = publications(:scientific_article)
    assert pub.validated?
  end

  test "validated? returns false with fewer than 2 validations" do
    pub = publications(:book_chapter)
    assert_not pub.validated?
  end

  test "create_journal_from_name creates journal on save" do
    pub = Publication.new(
      title: "Test",
      authors: "Author",
      publication_year: 2020,
      contributor: users(:admin_user),
      new_journal_name: "Brand New Journal"
    )
    assert_difference "Journal.count", 1 do
      pub.save!
    end
    assert_equal "Brand New Journal", pub.journal.name
  end

  test "create_journal_from_name does nothing when name blank" do
    pub = Publication.new(
      title: "Test",
      authors: "Author",
      publication_year: 2020,
      contributor: users(:admin_user),
      new_journal_name: ""
    )
    assert_no_difference "Journal.count" do
      pub.save!
    end
  end
end
