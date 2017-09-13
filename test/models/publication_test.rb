require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  test "relevance" do
    assert_equal [publications(:two)], (Publication.relevance "II").to_a
  end
end
