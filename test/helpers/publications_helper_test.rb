require 'test_helper'

class PublicationsHelperTest < ActionView::TestCase
  test "obtain_snippet returns text around search term" do
    contents = "This is a long piece of text about mesophotic coral ecosystems and their importance to marine biodiversity."
    result = obtain_snippet(contents, "mesophotic")
    assert_match(/mesophotic/, result)
    assert_match(/<strong>mesophotic<\/strong>/, result)
  end

  test "obtain_snippet returns ellipsis for blank contents" do
    assert_match(/…/, obtain_snippet("", "mesophotic"))
    assert_match(/…/, obtain_snippet(nil, "mesophotic"))
  end

  test "count_word_in_contents counts word occurrences" do
    result = count_word_in_contents("reef", "coral reef ecosystems on the reef")
    assert_equal 2, result
  end

  test "count_word_in_contents returns empty string for no matches" do
    result = count_word_in_contents("missing", "coral reef ecosystems")
    assert_equal "", result
  end

  test "count_word_in_contents is case insensitive" do
    result = count_word_in_contents("Reef", "coral reef ecosystems on the Reef")
    assert_equal 2, result
  end

  test "format_authors returns HTML safe string" do
    pub = publications(:scientific_article)
    result = format_authors(pub)
    assert result.html_safe?
    assert_includes result, "Smith"
  end

  test "format_publication_citation includes title and year" do
    pub = publications(:scientific_article)
    result = format_publication_citation(pub)
    assert_match(/Mesophotic coral ecosystems/, result)
    assert_match(/2020/, result)
  end

  test "format_publication_citation for chapter includes book info" do
    pub = publications(:book_chapter)
    result = format_publication_citation(pub)
    assert_match(/Coral Reef Science/, result)
    assert_match(/Academic Press/, result)
  end

  test "search_param generates checkbox list HTML" do
    params_hash = ActionController::Parameters.new({
      search_params: { "publication_types" => ["scientific", "popular"] }
    })
    result = search_param(
      "Types",
      ["scientific", "technical", "popular"],
      "publication_types",
      params_hash
    )
    assert result.html_safe?
    assert_match /Types/, result
    assert_match /scientific/, result
    assert_match /checkbox/, result
    # Verify checked items are marked
    assert_match /scientific.*checked/, result
    # Verify unchecked item does not have checked attribute within its own element
    technical_li = result[/publication_types\[technical\]\]"[^<]*>/, 0]
    assert_not_includes technical_li, "checked"
  end
end
