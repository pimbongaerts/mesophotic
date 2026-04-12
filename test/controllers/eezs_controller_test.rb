require 'test_helper'

class EezsControllerTest < ActionDispatch::IntegrationTest
  test "index renders successfully" do
    get eezs_path
    assert_response :success
  end

  test "index groups by sovereign" do
    get eezs_path
    assert_match "Australia", response.body
  end

  test "show renders for valid EEZ" do
    eez = eezs(:australian_gbr)
    get eez_path(eez)
    assert_response :success
    assert_match eez.territory, response.body
  end

  test "show displays sovereign" do
    eez = eezs(:australian_gbr)
    get eez_path(eez)
    assert_match eez.sovereign, response.body
  end

  test "show 404 for invalid EEZ" do
    get eez_path(id: 999999)
    assert_response :not_found
  end
end
