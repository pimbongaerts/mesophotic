require 'test_helper'

class EezTest < ActiveSupport::TestCase
  test "valid with all required fields" do
    eez = Eez.new(mrgid: 99999, geoname: "Test EEZ", sovereign: "Testland", territory: "Test Territory")
    assert eez.valid?
  end

  test "requires mrgid" do
    eez = Eez.new(geoname: "Test", sovereign: "Test", territory: "Test")
    assert_not eez.valid?
    assert eez.errors[:mrgid].any?
  end

  test "requires unique mrgid" do
    eez = Eez.new(mrgid: eezs(:australian_gbr).mrgid, geoname: "Dup", sovereign: "Dup", territory: "Dup")
    assert_not eez.valid?
    assert eez.errors[:mrgid].any?
  end

  test "requires geoname" do
    eez = Eez.new(mrgid: 99999, sovereign: "Test", territory: "Test")
    assert_not eez.valid?
    assert eez.errors[:geoname].any?
  end

  test "requires sovereign" do
    eez = Eez.new(mrgid: 99999, geoname: "Test", territory: "Test")
    assert_not eez.valid?
    assert eez.errors[:sovereign].any?
  end

  test "requires territory" do
    eez = Eez.new(mrgid: 99999, geoname: "Test", sovereign: "Test")
    assert_not eez.valid?
    assert eez.errors[:territory].any?
  end

  test "has many locations" do
    eez = eezs(:australian_gbr)
    assert_includes eez.locations, locations(:great_barrier_reef)
  end

  test "has many publications through locations" do
    eez = eezs(:australian_gbr)
    assert eez.publications.count >= 0
  end

  test ".sovereigns returns sorted distinct list" do
    sovereigns = Eez.sovereigns
    assert_kind_of Array, sovereigns
    assert_equal sovereigns, sovereigns.sort
    assert_equal sovereigns.uniq, sovereigns
  end

  test ".by_sovereign filters by sovereign name" do
    results = Eez.by_sovereign("Australia")
    results.each { |eez| assert_equal "Australia", eez.sovereign }
  end

  test ".with_publications returns only EEZs with linked publications" do
    results = Eez.with_publications
    results.each do |eez|
      assert eez.locations.joins(:publications).exists?
    end
  end
end
