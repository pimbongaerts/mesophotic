require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  test "relevance" do
    assert_equal [publications(:two)], (Publication.relevance "II").to_a
  end

  test "relevance scores" do
    scores = (Publication.relevance "Led Zeppelin")
    assert_equal 2, scores.first.relevance
    assert_equal 1, scores.last.relevance
  end

  test "no relevance" do
    assert_equal [], (Publication.relevance "Fred Astaire").to_a
  end

  test "filter" do
    assert_equal [publications(:two)], (Publication.filter "II").to_a
  end

  test "filtered everything" do
    assert_equal [], (Publication.filter "Fred Astaire").to_a
  end
end
