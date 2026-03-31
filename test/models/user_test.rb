require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "requires first_name" do
    user = User.new(last_name: "Test", email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "requires last_name" do
    user = User.new(first_name: "Test", email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "requires valid email" do
    user = User.new(first_name: "Test", last_name: "User", email: "notanemail", password: "password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "validates website format when present" do
    user = users(:regular_user)
    user.website = "not-a-url"
    assert_not user.valid?
  end

  test "allows blank website" do
    user = users(:regular_user)
    user.website = ""
    assert user.valid?
  end

  test "admin? true for admin" do
    assert users(:admin_user).admin?
  end

  test "admin? false for editor" do
    assert_not users(:editor_user).admin?
  end

  test "admin? false for regular user" do
    assert_not users(:regular_user).admin?
  end

  test "editor? true for admin (admin inherits editor)" do
    assert users(:admin_user).editor?
  end

  test "editor? true for editor" do
    assert users(:editor_user).editor?
  end

  test "editor? false for regular user" do
    assert_not users(:regular_user).editor?
  end

  test "editor_or_admin? delegates to editor?" do
    assert users(:admin_user).editor_or_admin?
    assert users(:editor_user).editor_or_admin?
    assert_not users(:regular_user).editor_or_admin?
  end

  test "role defaults to member" do
    user = User.new
    assert_equal "member", user.role
  end

  test "full_name returns last, first" do
    user = users(:admin_user)
    assert_equal "User, Admin", user.full_name
  end

  test "full_name_normal returns first last" do
    user = users(:admin_user)
    assert_equal "Admin User", user.full_name_normal
  end

  test "belongs to organisation" do
    user = users(:admin_user)
    assert_equal organisations(:csiro), user.organisation
  end

  test "organisation is optional" do
    user = users(:regular_user)
    assert_nil user.organisation
    assert user.valid?
  end

  test "paginates at 100" do
    assert_equal 100, User.default_per_page
  end

  test "create_organisation_from_name attempts to create organisation on save" do
    user = users(:regular_user)
    user.new_organisation_name = "New Org"
    # Organisation requires country which the callback doesn't provide,
    # so the organisation is built but not persisted
    user.save!
    org = user.organisation
    assert_equal "New Org", org.name
    assert_not org.persisted?
  end
end
