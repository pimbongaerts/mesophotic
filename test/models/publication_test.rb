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
    assert_equal [publications(:two)], (Publication.filter "II").to_a
  end

  test "filtered everything" do
    assert_equal [], (Publication.filter "Fred Astaire")
  end

  test "no filter" do
    assert_equal Publication.all, (Publication.filter "")
  end

  test "relevance" do
    assert_equal [publications(:two)], (Publication.relevance "II").to_a
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
end
