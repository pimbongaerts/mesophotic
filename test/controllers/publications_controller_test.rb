require 'test_helper'

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
