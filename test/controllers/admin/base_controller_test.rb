require 'test_helper'

class Admin::BaseControllerTest < ActionDispatch::IntegrationTest
  test "admin dashboard redirects unauthenticated user" do
    get admin_root_path
    assert_redirected_to new_user_session_path
  end

  test "admin dashboard redirects regular user" do
    sign_in users(:regular_user)
    get admin_root_path
    assert_redirected_to root_path
  end

  test "admin dashboard redirects editor" do
    sign_in users(:editor_user)
    get admin_root_path
    assert_redirected_to root_path
  end

  test "admin dashboard accessible to admin" do
    sign_in users(:admin_user)
    get admin_root_path
    assert_response :success
  end
end
