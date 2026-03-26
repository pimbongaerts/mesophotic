require 'test_helper'

class ValidationTest < ActiveSupport::TestCase
  test "requires user_id" do
    v = Validation.new(validatable_type: "Publication", validatable_id: 1)
    assert_not v.valid?
    assert_includes v.errors[:user_id], "can't be blank"
  end

  test "requires validatable_type" do
    v = Validation.new(user: users(:admin_user), validatable_id: 1)
    assert_not v.valid?
    assert_includes v.errors[:validatable_type], "can't be blank"
  end

  test "requires validatable_id" do
    v = Validation.new(user: users(:admin_user), validatable_type: "Publication")
    assert_not v.valid?
    assert_includes v.errors[:validatable_id], "can't be blank"
  end

  test "belongs to user" do
    v = validations(:validation_one)
    assert_equal users(:admin_user), v.user
  end

  test "belongs to validatable publication" do
    v = validations(:validation_one)
    assert_equal publications(:scientific_article), v.validatable
  end
end
