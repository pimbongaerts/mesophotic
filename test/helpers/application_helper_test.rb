require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "title sets page title" do
    title("Test Page")
    assert_equal "Test Page | Mesophotic.org", @title
  end

  test "title with nil does not set title" do
    title(nil)
    assert_nil @title
  end

  test "mesophotic_score counts mesophotic occurrences" do
    deep_count, word_count = mesophotic_score(
      "mesophotic coral ecosystems and deep reef habitats on the mesophotic zone"
    )
    # 2x "mesophotic" + 1x "deep reef" = 3
    assert_equal 3, deep_count
    assert_equal 11, word_count
  end

  test "mesophotic_score counts mce and mcr occurrences" do
    deep_count, _word_count = mesophotic_score("MCE and MCR are important deep reef ecosystems")
    assert_equal 3, deep_count  # mce + mcr + deep reef
  end

  test "mesophotic_score with no matches returns zero" do
    deep_count, word_count = mesophotic_score("shallow coral reefs")
    assert_equal 0, deep_count
    assert_equal 3, word_count
  end

  test "new_table_row_on_iteration returns row break on boundary" do
    result = new_table_row_on_iteration(4, 4)
    assert_equal "</tr><tr>", result
  end

  test "new_table_row_on_iteration returns nil when not on boundary" do
    result = new_table_row_on_iteration(3, 4)
    assert_nil result
  end

  test "new_table_row_on_iteration returns nil at zero" do
    result = new_table_row_on_iteration(0, 4)
    assert_nil result
  end

  test "word_association returns hash of model associations" do
    result = word_association
    assert result.is_a?(Hash)
    assert_includes result.keys, "platforms"
    assert_includes result.keys, "fields"
    assert_includes result.keys, "focusgroups"
    assert_includes result.keys, "locations"
  end

  test "species_association returns array of species data" do
    result = species_association
    assert result.is_a?(Array)
  end

  test "word_association returns same result on second call (cached)" do
    first = word_association
    second = word_association
    assert_equal first, second
  end

  test "species_association returns same result on second call (cached)" do
    first = species_association
    second = species_association
    assert_equal first, second
  end

  # linkify depends on word_association, species_association, and generates
  # link_to calls with summary_path which requires routing context not
  # available in a helper test. Skipping — better tested via integration tests.
end
