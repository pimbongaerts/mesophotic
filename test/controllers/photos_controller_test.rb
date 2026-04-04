require 'test_helper'

class PhotosControllerTest < ActionDispatch::IntegrationTest
  # index and show require Active Storage attachments on fixtures;
  # tested manually. These tests cover auth gates.

  test "new redirects unauthenticated user" do
    get new_photo_path
    assert_redirected_to new_user_session_path
  end

  test "new accessible to editor" do
    sign_in users(:editor_user)
    get new_photo_path
    assert_response :success
  end

  test "edit redirects unauthenticated user" do
    get edit_photo_path(photos(:cc_photo))
    assert_redirected_to new_user_session_path
  end
end
