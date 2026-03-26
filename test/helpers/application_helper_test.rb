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
end
