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
    assert_equal "Behind the science", post.category
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
