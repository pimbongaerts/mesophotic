require 'test_helper'

class LocationsControllerTest < ActionDispatch::IntegrationTest
  # index requires Active Storage attachments for featured location photo;
  # tested manually. These tests cover auth gates.

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
end
