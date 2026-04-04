require 'test_helper'

class Admin::PublicationsControllerTest < ActionDispatch::IntegrationTest
  test "dashboard redirects unauthenticated user" do
    get dashboard_admin_publications_path
    assert_redirected_to new_user_session_path
  end

  test "dashboard accessible to admin" do
    sign_in users(:admin_user)
    get dashboard_admin_publications_path
    assert_response :success
  end

  test "dashboard not accessible to editor" do
    sign_in users(:editor_user)
    get dashboard_admin_publications_path
    assert_redirected_to root_path
  end
end
