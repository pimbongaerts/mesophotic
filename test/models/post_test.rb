require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test "requires title" do
    post = Post.new(content_md: "Content", post_type: "announcement", user: users(:admin_user), featured_user: users(:admin_user))
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "requires content_md" do
    post = Post.new(title: "Title", post_type: "announcement", user: users(:admin_user), featured_user: users(:admin_user))
    assert_not post.valid?
    assert_includes post.errors[:content_md], "can't be blank"
  end

  test "requires post_type" do
    post = Post.new(title: "Title", content_md: "Content", user: users(:admin_user), featured_user: users(:admin_user))
    assert_not post.valid?
    assert_includes post.errors[:post_type], "can't be blank"
  end

  test "requires featured_publication for behind_the_science" do
    post = Post.new(
      title: "BTS Post",
      content_md: "Content",
      post_type: "behind_the_science",
      user: users(:admin_user),
      featured_user: users(:admin_user)
    )
    assert_not post.valid?
    assert post.errors[:featured_publication_id].any? || post.errors[:featured_publication].any?
  end

  test "title must be unique" do
    post = Post.new(
      title: posts(:published_post).title,
      content_md: "Content",
      post_type: "announcement",
      user: users(:admin_user),
      featured_user: users(:admin_user)
    )
    assert_not post.valid?
    assert_includes post.errors[:title], "has already been taken"
  end

  test "renders markdown to HTML on save" do
    post = Post.new(
      title: "Markdown Test Post",
      content_md: "This is **bold** text.",
      post_type: "announcement",
      user: users(:admin_user),
      featured_user: users(:admin_user)
    )
    post.save!
    assert_match "<strong>bold</strong>", post.content_html
  end

  test "published scope returns non-draft posts" do
    published = Post.published
    assert_includes published, posts(:published_post)
    assert_not_includes published, posts(:drafted_post)
  end

  test "drafted scope returns draft posts" do
    drafted = Post.drafted
    assert_includes drafted, posts(:drafted_post)
    assert_not_includes drafted, posts(:published_post)
  end

  test "latest scope limits results" do
    latest = Post.latest(1)
    assert_equal 1, latest.length
  end

  test "category returns human-readable name" do
    post = posts(:published_post)
    assert_equal "Behind the Science", post.category
  end

  test "requires featured_user for early_career" do
    post = Post.new(
      title: "EC Post",
      content_md: "Content",
      post_type: "early_career",
      user: users(:admin_user)
    )
    assert_not post.valid?
    # Error may be on :featured_user (belongs_to) or :featured_user_id (conditional validation)
    assert post.errors[:featured_user_id].any? || post.errors[:featured_user].any?
  end

  test "post without featured_user is valid for behind_the_science" do
    post = Post.new(
      title: "No Featured User BTS",
      content_md: "Content",
      post_type: "behind_the_science",
      user: users(:admin_user),
      featured_publication: publications(:scientific_article)
    )
    assert post.valid?
  end

  test "post without featured_user is valid for announcement" do
    post = Post.new(
      title: "No Featured User Announcement",
      content_md: "Content",
      post_type: "announcement",
      user: users(:admin_user)
    )
    assert post.valid?
  end

  # -- method_feature validations --

  test "method_feature requires both featured_publication and featured_user" do
    post = Post.new(
      title: "Method Post",
      content_md: "Content",
      post_type: "method_feature",
      user: users(:admin_user)
    )
    assert_not post.valid?
    assert post.errors[:featured_publication_id].any? || post.errors[:featured_publication].any?
    assert post.errors[:featured_user_id].any? || post.errors[:featured_user].any?
  end

  test "method_feature is valid with both featured_publication and featured_user" do
    post = Post.new(
      title: "Valid Method Post",
      content_md: "Content",
      post_type: "method_feature",
      user: users(:admin_user),
      featured_user: users(:admin_user),
      featured_publication: publications(:scientific_article)
    )
    assert post.valid?
  end

  # -- parsed_content --

  test "parsed_content returns empty array for nil content" do
    post = Post.new(content_md: nil)
    assert_equal [], post.parsed_content
  end

  test "parsed_content returns sections for normal headings" do
    post = Post.new(content_md: "#### Question one\nAnswer\n\n#### Question two\nAnswer")
    blocks = post.parsed_content
    assert_equal 2, blocks.length
    assert_equal :section, blocks[0][:type]
    assert_equal :section, blocks[1][:type]
  end

  test "parsed_content groups consecutive quick questions" do
    post = Post.new(content_md: "##### Q1\nA1\n\n##### Q2\nA2\n\n#### Normal\nAnswer")
    blocks = post.parsed_content
    assert_equal 2, blocks.length
    assert_equal :quick_question_group, blocks[0][:type]
    assert_equal 2, blocks[0][:questions].length
    assert_equal :section, blocks[1][:type]
  end

  test "parsed_content separates non-consecutive quick question groups" do
    post = Post.new(content_md: "##### Q1\nA1\n\n#### Normal\nAnswer\n\n##### Q2\nA2")
    blocks = post.parsed_content
    assert_equal 3, blocks.length
    assert_equal :quick_question_group, blocks[0][:type]
    assert_equal 1, blocks[0][:questions].length
    assert_equal :section, blocks[1][:type]
    assert_equal :quick_question_group, blocks[2][:type]
    assert_equal 1, blocks[2][:questions].length
  end

  test "parsed_content handles all quick questions" do
    post = Post.new(content_md: "##### Q1\nA1\n\n##### Q2\nA2\n\n##### Q3\nA3")
    blocks = post.parsed_content
    assert_equal 1, blocks.length
    assert_equal :quick_question_group, blocks[0][:type]
    assert_equal 3, blocks[0][:questions].length
  end

  test "parsed_content handles all normal sections" do
    post = Post.new(content_md: "#### S1\nA1\n\n#### S2\nA2")
    blocks = post.parsed_content
    assert_equal 2, blocks.length
    assert blocks.all? { |b| b[:type] == :section }
  end

  test "parsed_content skips blank sections" do
    post = Post.new(content_md: "#### S1\nA1\n\n\n\n#### S2\nA2")
    blocks = post.parsed_content
    assert_equal 2, blocks.length
  end

  # -- Line ending normalisation --

  test "normalises Windows line endings on save" do
    post = Post.new(
      title: "Windows Line Endings",
      content_md: "Section one\r\n\r\nSection two\r\n\r\nSection three",
      post_type: "announcement",
      user: users(:admin_user)
    )
    post.save!
    assert_equal "Section one\n\nSection two\n\nSection three", post.content_md
    assert_not_includes post.content_md, "\r"
  end

  test "normalises old Mac line endings on save" do
    post = Post.new(
      title: "Mac Line Endings",
      content_md: "Section one\r\rSection two",
      post_type: "announcement",
      user: users(:admin_user)
    )
    post.save!
    assert_not_includes post.content_md, "\r"
  end

  test "preserves Unix line endings on save" do
    post = Post.new(
      title: "Unix Line Endings",
      content_md: "Section one\n\nSection two",
      post_type: "announcement",
      user: users(:admin_user)
    )
    post.save!
    assert_equal "Section one\n\nSection two", post.content_md
  end

  test "normalisation runs before markdown rendering" do
    post = Post.new(
      title: "Render After Normalise",
      content_md: "**bold**\r\n\r\n*italic*",
      post_type: "announcement",
      user: users(:admin_user)
    )
    post.save!
    assert_match "<strong>bold</strong>", post.content_html
    assert_match "<em>italic</em>", post.content_html
  end

  test "generates slug from title" do
    post = Post.new(
      title: "A New Unique Post Title",
      content_md: "Content here",
      post_type: "announcement",
      user: users(:admin_user),
      featured_user: users(:admin_user)
    )
    post.save!
    assert_equal "a-new-unique-post-title", post.slug
  end
end
