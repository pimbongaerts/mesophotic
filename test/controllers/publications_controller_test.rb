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

  test "create sets contributor to current user" do
    sign_in users(:editor_user)
    post publications_path, params: {
      publication: { title: "Contributor Test", authors: "Author A", publication_year: 2021 }
    }
    pub = Publication.find_by(title: "Contributor Test")
    assert_equal users(:editor_user), pub.contributor
  end

  test "update succeeds for publication without contributor" do
    sign_in users(:editor_user)
    pub = publications(:one) # has no contributor
    patch publication_path(pub), params: {
      publication: { title: "Updated Title" }
    }
    assert_equal "Updated Title", pub.reload.title
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
  test "CSV redirects unauthenticated user" do
    get publications_path(format: :csv)
    assert_response :unauthorized
  end

  test "CSV accessible to authenticated user" do
    sign_in users(:regular_user)
    get publications_path(format: :csv)
    assert_response :success
  end

  test "CSV without search has no occurrences column" do
    sign_in users(:regular_user)
    get publications_path(format: :csv)
    lines = response.body.lines
    header = lines.first
    assert_not_includes header, "occurrences"
    assert_no_match(/# Search term:/, response.body)
  end

  test "CSV with search includes occurrences column and search term comment" do
    sign_in users(:regular_user)
    get publications_path(format: :csv, search: "mesophotic")
    lines = response.body.lines
    assert_match(/# Search term: mesophotic/, lines.first)
    header = lines.second
    assert_includes header, "occurrences"
  end

  test "CSV with search for editor does not include occurrences" do
    sign_in users(:editor_user)
    get publications_path(format: :csv, search: "mesophotic")
    assert_not_includes response.body, "occurrences"
    assert_no_match(/# Search term:/, response.body)
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
        result = @controller.send(:search_params, ActionController::Parameters.new({"fields" => {"title" => "title", "author" => "author"}}))
        assert_equal({"fields" => ["title", "author"]}, result)
    end

    test "search params, array" do
        result = @controller.send(:search_params, ActionController::Parameters.new({"fields" => ["title", "author"]}))
        assert_equal({"fields" => ["title", "author"]}, result)
    end
end
