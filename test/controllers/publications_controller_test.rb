require 'test_helper'

class PublicationsControllerIntegrationTest < ActionDispatch::IntegrationTest
  # Public access
  test "index returns success" do
    get publications_path
    assert_response :success
  end

  test "index with search params returns success" do
    get publications_path, params: { search: "reef" }
    assert_response :success
  end

  test "show returns success" do
    get publication_path(publications(:scientific_article))
    assert_response :success
  end

  # Auth gates
  test "new redirects unauthenticated user" do
    get new_publication_path
    assert_redirected_to new_user_session_path
  end

  test "new accessible to editor" do
    sign_in users(:editor_user)
    get new_publication_path
    assert_response :success
  end

  test "new accessible to admin" do
    sign_in users(:admin_user)
    get new_publication_path
    assert_response :success
  end

  test "edit redirects unauthenticated user" do
    get edit_publication_path(publications(:scientific_article))
    assert_redirected_to new_user_session_path
  end

  test "edit accessible to editor" do
    sign_in users(:editor_user)
    get edit_publication_path(publications(:scientific_article))
    assert_response :success
  end

  test "create redirects unauthenticated user" do
    post publications_path, params: { publication: { title: "Test", authors: "A", publication_year: 2020 } }
    assert_redirected_to new_user_session_path
  end

  test "create succeeds for editor" do
    sign_in users(:editor_user)
    assert_difference "Publication.count", 1 do
      post publications_path, params: {
        publication: { title: "New Pub", authors: "Author A", publication_year: 2021 }
      }
    end
  end

  test "destroy redirects unauthenticated user" do
    delete publication_path(publications(:scientific_article))
    assert_redirected_to new_user_session_path
  end

  test "destroy succeeds for admin" do
    sign_in users(:admin_user)
    assert_difference "Publication.count", -1 do
      delete publication_path(publications(:scientific_article))
    end
  end

  # CSV export
  test "index responds to CSV format" do
    get publications_path(format: :csv)
    assert_response :success
  end
end

class PublicationsControllerTest < ActionController::TestCase
    test "search params, empty" do
        assert_equal(
            ActionController::Parameters.new({}),
            @controller.send(:search_params, ActionController::Parameters.new({}))
        )
    end

    test "search params, nil" do
        assert_nil(@controller.send(:search_params, nil))
    end

    test "search params, hash" do
        assert_equal(
            ActionController::Parameters.new({"fields" => ["title", "author"]}),
            @controller.send(:search_params, ActionController::Parameters.new({"fields" => {"title" => "title", "author" => "author"}}))
        )
    end

    test "search params, array" do
        assert_equal(
            ActionController::Parameters.new({"fields" => ["title", "author"]}),
            @controller.send(:search_params, ActionController::Parameters.new({"fields" => ["title", "author"]}))
        )
    end
end
