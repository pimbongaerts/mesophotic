require 'test_helper'

class DualRangeHelperTest < ActionView::TestCase
  test "dual_range_slider renders HTML with inputs" do
    result = dual_range_slider("search_params[year_range]", {
      min: 1970,
      max: 2024,
      step: 1,
      value: "1990,2020",
      id: "year_range"
    })
    assert_match(/input/, result)
    assert_match(/year_range/, result)
    assert_match(/1990/, result)
    assert_match(/2020/, result)
  end

  test "dual_range_slider with default values" do
    result = dual_range_slider("test_range", {
      min: 0,
      max: 100,
      step: 5
    })
    assert_match(/input/, result)
    assert_match(/dual-range/, result)
  end

  test "dual_range_slider includes hidden input with name" do
    result = dual_range_slider("depth_range", {
      min: 0,
      max: 200,
      step: 10,
      value: "30,150"
    })
    assert_match(/type="hidden"/, result)
    assert_match(/name="depth_range"/, result)
    assert_match(/value="30,150"/, result)
  end
end
