require 'test_helper'

class SpeciesControllerTest < ActionDispatch::IntegrationTest
  test "index returns success" do
    get species_index_path
    assert_response :success
  end

  test "edit redirects unauthenticated user" do
    get edit_species_path(species(:chromis_margaritifer))
    assert_redirected_to new_user_session_path
  end

  test "species_image returns success" do
    get species_image_path(id: species(:chromis_margaritifer).id)
    assert_response :success
  end
end
