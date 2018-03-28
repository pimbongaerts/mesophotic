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
    assert_equal (Publication.filter "II"), (Publication.search "II", Publication.default_search_params, true)
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

  test "filter" do
    assert_equal [publications(:three), publications(:two)], (Publication.filter "II").to_a
  end

  test "filtered everything" do
    assert_equal [], (Publication.filter "Fred Astaire")
  end

  test "no filter" do
    assert_equal Publication.all, (Publication.filter "")
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
    assert_equal [publications(:three), publications(:one)], (Publication.search "", Publication.default_search_params.merge("depth_range" => "40, 200")).to_a
  end

  test "depth search, find one" do
    assert_equal [publications(:one)], (Publication.search "", Publication.default_search_params.merge("depth_range" => "200, 300")).to_a
  end
end
