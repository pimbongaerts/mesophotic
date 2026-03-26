require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  test "showcases_location scope returns underwater showcase photos" do
    showcase = Photo.showcases_location
    assert_includes showcase, photos(:cc_photo)
    assert_not_includes showcase, photos(:regular_photo)
  end

  test "media_gallery scope returns creative commons photos" do
    gallery = Photo.media_gallery
    assert_includes gallery, photos(:cc_photo)
    assert_not_includes gallery, photos(:regular_photo)
  end

  test "belongs to photographer" do
    photo = photos(:cc_photo)
    assert_equal users(:regular_user), photo.photographer
  end

  test "belongs to location" do
    photo = photos(:cc_photo)
    assert_equal locations(:great_barrier_reef), photo.location
  end

  test "has_place? true when location present" do
    photo = photos(:cc_photo)
    assert photo.has_place?
  end

  test "has_place? false when no location or site" do
    photo = photos(:regular_photo)
    assert_not photo.has_place?
  end

  test "description_truncated truncates long descriptions" do
    photo = photos(:cc_photo)
    assert photo.description_truncated.length <= 73
  end
end
