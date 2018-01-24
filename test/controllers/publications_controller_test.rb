require 'test_helper'

class PublicationsControllerTest < ActionController::TestCase
    test "search params, empty" do
        assert_equal({}, @controller.send(:search_params, {}))
    end

    test "search params, nil" do
        assert_nil(@controller.send(:search_params, nil))
    end

    test "search params, hash" do
        assert_equal({"fields" => ["title", "author"]}, @controller.send(:search_params, {"fields" => {"title" => "title", "author" => "author"}}))
    end

    test "search params, array" do
        assert_equal({"fields" => ["title", "author"]}, @controller.send(:search_params, {"fields" => ["title", "author"]}))
    end
end
