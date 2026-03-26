require 'test_helper'

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "all statistics returns success" do
    get all_stats_path(year: 2023)
    assert_response :success
  end

  test "validated statistics returns success" do
    get validated_stats_path(year: 2023)
    assert_response :success
  end
end
