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

  # Turbo Frame endpoints — these require status and year params
  # and return turbo-frame wrapped HTML

  test "summarized_fields returns success" do
    get summarized_fields_path(status: :all, year: 2023)
    assert_response :success
  end

  test "summarized_journals returns success" do
    get summarized_journals_path(status: :all, year: 2023)
    assert_response :success
  end

  test "summarized_focusgroups returns success" do
    get summarized_focusgroups_path(status: :all, year: 2023)
    assert_response :success
  end

  test "summarized_platforms returns success" do
    get summarized_platforms_path(status: :all, year: 2023)
    assert_response :success
  end

  test "world_publications returns success" do
    get world_publications_path(status: :all, year: 2023)
    assert_response :success
  end

  test "world_locations returns success" do
    get world_locations_path(status: :all, year: 2023)
    assert_response :success
  end

  test "growing_depth_range returns success" do
    get growing_depth_range_path(status: :all, year: 2023)
    assert_response :success
  end

  test "growing_publications_over_time returns success" do
    get growing_publications_over_time_path(status: :all, year: 2023)
    assert_response :success
  end

  test "growing_locations_over_time returns success" do
    get growing_locations_over_time_path(status: :all, year: 2023)
    assert_response :success
  end

  test "growing_authors_over_time returns success" do
    get growing_authors_over_time_path(status: :all, year: 2023)
    assert_response :success
  end

  test "time_refuge returns success" do
    get time_refuge_path(status: :all, year: 2023)
    assert_response :success
  end

  test "time_mesophotic returns success" do
    get time_mesophotic_path(status: :all, year: 2023)
    assert_response :success
  end

  # Validated status uses a different scope path
  test "summarized_fields with validated status returns success" do
    get summarized_fields_path(status: :validated, year: 2023)
    assert_response :success
  end

  test "summarized_journals with validated status returns success" do
    get summarized_journals_path(status: :validated, year: 2023)
    assert_response :success
  end

  # Verify turbo-frame responses contain expected frame IDs
  test "summarized_fields response contains turbo frame" do
    get summarized_fields_path(status: :all, year: 2023)
    assert_match(/turbo-frame.*stats-summarized_fields/, response.body)
  end

  test "summarized_journals response contains turbo frame" do
    get summarized_journals_path(status: :all, year: 2023)
    assert_match(/turbo-frame.*stats-summarized_journals/, response.body)
  end

  test "world_locations response contains turbo frame" do
    get world_locations_path(status: :all, year: 2023)
    assert_match(/turbo-frame.*stats-world_locations/, response.body)
  end
end
