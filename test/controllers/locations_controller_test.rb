require 'test_helper'

class LocationsControllerTest < ActionDispatch::IntegrationTest
  # index requires Active Storage attachments for featured location photo;
  # tested manually. These tests cover auth gates.

  # --- auth gates ---

  test "new redirects unauthenticated user" do
    get new_location_path
    assert_redirected_to new_user_session_path
  end

  test "new accessible to editor" do
    sign_in users(:editor_user)
    get new_location_path
    assert_response :success
  end

  test "edit redirects unauthenticated user" do
    get edit_location_path(locations(:great_barrier_reef))
    assert_redirected_to new_user_session_path
  end

  test "edit accessible to editor" do
    sign_in users(:editor_user)
    get edit_location_path(locations(:great_barrier_reef))
    assert_response :success
  end

  test "create redirects unauthenticated user" do
    post locations_path, params: { location: { description: "Test", latitude: 10, longitude: 20 } }
    assert_redirected_to new_user_session_path
  end

  # --- new form rendering ---

  test "new form has required field indicators" do
    sign_in users(:editor_user)
    get new_location_path
    assert_select 'label.required', count: 3
  end

  test "new form has placeholder text" do
    sign_in users(:editor_user)
    get new_location_path
    assert_select 'input[placeholder]', minimum: 3
  end

  test "new form has map preview element" do
    sign_in users(:editor_user)
    get new_location_path
    assert_select '[data-chart="map-preview"]'
  end

  test "new form has cancel button" do
    sign_in users(:editor_user)
    get new_location_path
    assert_select 'a[href=?]', locations_path, text: "Cancel"
  end

  # --- edit form rendering ---

  test "edit form shows location name in title" do
    sign_in users(:editor_user)
    loc = locations(:great_barrier_reef)
    get edit_location_path(loc)
    assert_match /Editing/, response.body
    assert_match loc.description, response.body
  end

  test "edit form has required field indicators" do
    sign_in users(:editor_user)
    get edit_location_path(locations(:great_barrier_reef))
    assert_select 'label.required', count: 3
  end

  test "edit form has live map preview" do
    sign_in users(:editor_user)
    get edit_location_path(locations(:great_barrier_reef))
    assert_select '[data-chart="map-preview"]'
  end

  test "edit form has cancel button" do
    sign_in users(:editor_user)
    get edit_location_path(locations(:great_barrier_reef))
    assert_select 'a[href=?]', locations_path, text: "Cancel"
  end

  # --- create ---

  test "create succeeds for editor with valid params" do
    sign_in users(:editor_user)
    assert_difference 'Location.count', 1 do
      post locations_path, params: { location: { description: "New Reef", latitude: -15.5, longitude: 145.8 } }
    end
    assert_redirected_to edit_location_path(Location.last)
  end

  test "create fails with missing description" do
    sign_in users(:editor_user)
    assert_no_difference 'Location.count' do
      post locations_path, params: { location: { description: "", latitude: -15.5, longitude: 145.8 } }
    end
    assert_response :success # re-renders form
  end

  test "create fails with missing latitude" do
    sign_in users(:editor_user)
    assert_no_difference 'Location.count' do
      post locations_path, params: { location: { description: "Test", latitude: "", longitude: 145.8 } }
    end
    assert_response :success
  end

  test "create fails with missing longitude" do
    sign_in users(:editor_user)
    assert_no_difference 'Location.count' do
      post locations_path, params: { location: { description: "Test", latitude: -15.5, longitude: "" } }
    end
    assert_response :success
  end

  test "create fails with out-of-range latitude" do
    sign_in users(:editor_user)
    assert_no_difference 'Location.count' do
      post locations_path, params: { location: { description: "Test", latitude: 91, longitude: 145.8 } }
    end
    assert_response :success
  end

  # --- update ---

  test "update succeeds for editor" do
    sign_in users(:editor_user)
    loc = locations(:great_barrier_reef)
    patch location_path(loc), params: { location: { description: "Updated Reef" } }
    assert_redirected_to edit_location_path(loc)
    assert_equal "Updated Reef", loc.reload.description
  end

  test "update fails with blank description" do
    sign_in users(:editor_user)
    loc = locations(:great_barrier_reef)
    patch location_path(loc), params: { location: { description: "" } }
    assert_response :success
    assert_not_equal "", loc.reload.description
  end
end
