require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test "requires description" do
    loc = Location.new(latitude: 0, longitude: 0)
    assert_not loc.valid?
    assert_includes loc.errors[:description], "can't be blank"
  end

  test "requires latitude" do
    loc = Location.new(description: "Test", latitude: nil, longitude: 0)
    assert_not loc.valid?
    assert loc.errors[:latitude].any?
  end

  test "requires longitude" do
    loc = Location.new(description: "Test", latitude: 0, longitude: nil)
    assert_not loc.valid?
    assert loc.errors[:longitude].any?
  end

  test "validates latitude range" do
    loc = Location.new(description: "Test", latitude: 91, longitude: 0)
    assert_not loc.valid?
  end

  test "validates longitude range" do
    loc = Location.new(description: "Test", latitude: 0, longitude: 181)
    assert_not loc.valid?
  end

  test "place_data returns hash with location info" do
    loc = locations(:great_barrier_reef)
    data = loc.place_data(5)
    assert_equal "Great Barrier Reef", data[:name]
    assert_equal 5, data[:z]
    assert data[:lat].present?
    assert data[:lon].present?
  end

  test "has many sites" do
    loc = locations(:great_barrier_reef)
    assert_includes loc.sites, sites(:osprey_reef)
  end
end
