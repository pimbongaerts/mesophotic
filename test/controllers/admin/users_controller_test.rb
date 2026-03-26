require 'test_helper'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "index redirects unauthenticated user" do
    get admin_users_path
    assert_redirected_to new_user_session_path
  end

  test "index redirects non-admin" do
    sign_in users(:editor_user)
    get admin_users_path
    assert_redirected_to root_path
  end

  test "index accessible to admin" do
    sign_in users(:admin_user)
    get admin_users_path
    assert_response :success
  end

  test "edit accessible to admin" do
    sign_in users(:admin_user)
    get edit_admin_user_path(users(:regular_user))
    assert_response :success
  end

  test "admin cannot change own admin status" do
    sign_in users(:admin_user)
    patch admin_user_path(users(:admin_user)), params: {
      user: { email: users(:admin_user).email, password: "", password_confirmation: "", admin: "0" }
    }
    users(:admin_user).reload
    assert users(:admin_user).admin?
  end
end
