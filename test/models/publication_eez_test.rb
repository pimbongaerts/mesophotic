require 'test_helper'

class PublicationEezTest < ActiveSupport::TestCase
  test ".by_sovereign returns publications in sovereign's EEZs" do
    results = Publication.by_sovereign(["Australia"])
    results.each do |pub|
      sovereigns = pub.locations.filter_map { |l| l.eez&.sovereign }
      assert_includes sovereigns, "Australia"
    end
  end

  test ".by_sovereign with nil returns all" do
    assert_equal Publication.all.count, Publication.by_sovereign(nil).count
  end

  test ".publication_sovereigns returns sorted unique list" do
    sovereigns = Publication.publication_sovereigns
    assert_kind_of Array, sovereigns
    assert_equal sovereigns, sovereigns.sort
    assert_equal sovereigns.uniq, sovereigns
  end

  test "csv_header includes EEZ columns" do
    header = Publication.csv_header
    assert_includes header, "eez_sovereign"
    assert_includes header, "eez_territory"
  end
end
