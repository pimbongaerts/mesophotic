require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home returns success" do
    get root_path
    assert_response :success
  end

  test "about returns success" do
    get about_pages_path
    assert_response :success
  end

  # members page requires users with publications AND profile pictures
  # (ActiveStorage) for the featured member partial; skipped because
  # fixtures do not set up ActiveStorage attachments.

  test "show_member returns success" do
    get member_pages_path(users(:regular_user))
    assert_response :success
  end

  test "show_member with invalid id redirects" do
    get member_pages_path(id: 999999)
    assert_redirected_to root_path
  end

  # media_gallery page requires photos with ActiveStorage image
  # attachments for variant processing; skipped because fixtures
  # do not set up ActiveStorage attachments.

  test "posts returns success" do
    get posts_pages_path
    assert_response :success
  end

  test "show_post returns success" do
    get post_pages_path(posts(:published_post))
    assert_response :success
  end

  # -- Post type rendering --

  test "behind_the_science post shows An Interview With" do
    get post_pages_path(posts(:published_post))
    assert_response :success
    assert_match /An Interview With/, response.body
  end

  test "behind_the_science post shows featured publication link" do
    get post_pages_path(posts(:published_post))
    assert_match /Featured Article/, response.body
  end

  test "announcement post shows Posted By" do
    get post_pages_path(posts(:announcement_post))
    assert_response :success
    assert_match /Posted By/, response.body
    assert_no_match /An Interview With/, response.body
  end

  test "announcement post shows title in quotes" do
    get post_pages_path(posts(:announcement_post))
    assert_match /Collaborative Mesophotic Project/, response.body
  end

  test "announcement post does not show location map" do
    get post_pages_path(posts(:announcement_post))
    assert_no_match /Study Location/, response.body
  end

  test "announcement post does not show publication metadata" do
    get post_pages_path(posts(:announcement_post))
    assert_no_match /Publication Metadata/, response.body
  end

  test "early_career post shows quick questions in card" do
    get post_pages_path(posts(:ecr_post))
    assert_response :success
    assert_match /Mee-so or meh-so/, response.body
    assert_match /Charismatic megafauna/, response.body
  end

  test "early_career post shows An Interview With" do
    get post_pages_path(posts(:ecr_post))
    assert_match /An Interview With/, response.body
  end

  # -- Admin dropdown menu --

  test "admin user sees quick-create links in navigation" do
    sign_in users(:admin_user)
    get root_path
    assert_match /New Publication/, response.body
    assert_match /New Post/, response.body
    assert_match /New Photo/, response.body
    assert_match /Dashboard/, response.body
  end

  test "regular user does not see quick-create links" do
    sign_in users(:regular_user)
    get root_path
    assert_no_match /New Publication/, response.body
    assert_no_match /New Post/, response.body
    assert_no_match /New Photo/, response.body
  end

  test "unauthenticated user does not see quick-create links" do
    get root_path
    assert_no_match /New Publication/, response.body
    assert_no_match /New Post/, response.body
  end

  test "inside redirects unauthenticated user" do
    get inside_pages_path
    assert_redirected_to new_user_session_path
  end

  test "inside accessible to editor" do
    sign_in users(:editor_user)
    get inside_pages_path
    assert_response :success
  end

  test "contact returns success" do
    get contact_pages_path
    assert_response :success
  end

  test "email with valid params sends mail and redirects" do
    ENV["SENDER_EMAIL"] = "test@mesophotic.org"
    post email_confirmation_pages_path, params: {
      name: "Test User",
      email: "test@example.com",
      message: "This is a test message with enough characters."
    }
    assert_redirected_to root_path
  ensure
    ENV.delete("SENDER_EMAIL")
  end

  test "email with invalid params renders contact" do
    post email_confirmation_pages_path, params: {
      name: "",
      email: "test@example.com",
      message: "Test message with enough characters."
    }
    assert_response :success
  end
end
