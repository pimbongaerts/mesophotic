require 'test_helper'

class StatsQueryTest < ActionDispatch::IntegrationTest
  # Integration tests for stats controller summarized endpoints.
  # These call the REAL controller actions and verify the HTML response
  # contains expected data based on fixtures.
  #
  # Fixtures define 4 mesophotic scientific articles (year 2020):
  #   scientific_article: ecology+genetics, corals, scuba+rov, GBR, open_journal
  #   stats_ecology_gbr: ecology, corals, scuba, GBR, open_journal
  #   stats_genetics_gbr: genetics, corals, rov, GBR, closed_journal
  #   stats_ecology_redsea: ecology, fish, scuba, Red Sea, open_journal
  #
  # Expected field counts: ecology=3, genetics=2
  # Expected focusgroup counts: corals=3, fish=1
  # Expected platform counts: SCUBA=3, ROV=2
  # Expected location counts: GBR=3, Red Sea=1
  # Expected journal counts: open=3, closed=1

  test "summarized_fields shows ecology with count 3" do
    get summarized_fields_path(status: :all, year: 2023)
    assert_response :success
    assert_select_count_for "Ecology", 3
  end

  test "summarized_fields shows genetics with count 2" do
    get summarized_fields_path(status: :all, year: 2023)
    assert_response :success
    assert_select_count_for "Genetics", 2
  end

  test "summarized_focusgroups shows corals with count 3" do
    get summarized_focusgroups_path(status: :all, year: 2023)
    assert_response :success
    assert_select_count_for "Corals", 3
  end

  test "summarized_focusgroups shows fish with count 1" do
    get summarized_focusgroups_path(status: :all, year: 2023)
    assert_response :success
    assert_select_count_for "Fish", 1
  end

  test "summarized_platforms shows scuba with count 3" do
    get summarized_platforms_path(status: :all, year: 2023)
    assert_response :success
    assert_select_count_for "SCUBA diving", 3
  end

  test "summarized_platforms shows rov with count 2" do
    get summarized_platforms_path(status: :all, year: 2023)
    assert_response :success
    assert_select_count_for "Remotely Operated Vehicle", 2
  end

  test "world_locations shows gbr and red sea" do
    get world_locations_path(status: :all, year: 2023)
    assert_response :success
    assert_match(/Great Barrier Reef/, response.body)
    assert_match(/Red Sea/, response.body)
    # Chart renders percentages: GBR=75%, Red Sea=25%
    assert_match(/75\.0/, response.body)
    assert_match(/25\.0/, response.body)
  end

  test "summarized_journals shows open access with count 3" do
    get summarized_journals_path(status: :all, year: 2023)
    assert_response :success
    assert_select_count_for "Open Access Journal", 3
  end

  test "summarized_journals shows closed with count 1" do
    get summarized_journals_path(status: :all, year: 2023)
    assert_response :success
    assert_select_count_for "Closed Journal", 1
  end

  test "all turbo frame endpoints return success" do
    [
      summarized_fields_path, summarized_journals_path,
      summarized_focusgroups_path, summarized_platforms_path,
      world_locations_path, world_publications_path,
      growing_depth_range_path, growing_publications_over_time_path,
      growing_locations_over_time_path, growing_authors_over_time_path,
      time_refuge_path, time_mesophotic_path
    ].each do |path|
      get path, params: { status: :all, year: 2023 }
      assert_response :success, "Expected success for #{path}"
    end
  end

  private

  # Assert the response body contains the description and its associated count.
  # The stats partials render counts in <td> tags adjacent to descriptions.
  def assert_select_count_for(description, expected_count)
    assert_match(/#{Regexp.escape(description)}/, response.body,
      "Expected '#{description}' in response")
    assert_match(/#{expected_count}/, response.body,
      "Expected count #{expected_count} for '#{description}' in response")
  end
end
