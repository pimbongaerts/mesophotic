require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase
  test "belongs to focusgroup" do
    species = species(:chromis_margaritifer)
    assert_equal focusgroups(:fish), species.focusgroup
  end

  test "abbreviation returns abbreviated name" do
    species = species(:chromis_margaritifer)
    abbrev = species.abbreviation
    assert abbrev.start_with?("C")
    assert_match /margaritifer/, abbrev
  end

  test "description returns name" do
    species = species(:chromis_margaritifer)
    assert_equal "Chromis margaritifer", species.description
  end

  test "short_description includes name and abbreviation" do
    species = species(:chromis_margaritifer)
    desc = species.short_description
    assert_match /Chromis margaritifer/, desc
    assert_match /;/, desc
  end

  test "species_code returns parameterized name" do
    species = species(:chromis_margaritifer)
    assert_equal "chromis-margaritifer", species.species_code
  end

  test "after_create triggers speciate" do
    Species.skip_callback(:create, :after, :speciate)
    species = Species.create!(name: "Acropora palmata", focusgroup: focusgroups(:corals))
    assert species.persisted?
  ensure
    Species.set_callback(:create, :after, :speciate)
  end
end
