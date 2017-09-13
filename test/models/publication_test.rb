require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  test "search, find something" do
    assert_equal (Publication.filter "II", ["title"], ["popular"]), (Publication.search "II", ["title"], ["popular"], true)
    assert_equal (Publication.relevance "II", ["title"], ["popular"]), (Publication.search "II", ["title"], ["popular"], false)
    assert_equal (Publication.relevance "II", ["title"], ["popular"]), (Publication.search "II", ["title"], ["popular"])
    assert_equal (Publication.relevance "II"), (Publication.search "II")
  end

  test "search, find nothing" do
    assert_equal [], (Publication.search "Fred Astaire", ["title"], ["popular"], true)
    assert_equal [], (Publication.search "Ginger Rogers", ["title"], ["popular"], false)
    assert_equal [], (Publication.search "James Dean", ["title"], ["popular"])
    assert_equal [], (Publication.search "Marilyn Monroe")
  end

  test "empty search" do
    assert_equal Publication.all.order(:id).to_a, (Publication.search "", ["title"], ["popular"], true).to_a
    assert_equal Publication.all.order(:id).to_a, (Publication.search "", ["title"], ["popular"], false).to_a
    assert_equal Publication.all.order(:id).to_a, (Publication.search "", ["title"], ["popular"]).to_a
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
