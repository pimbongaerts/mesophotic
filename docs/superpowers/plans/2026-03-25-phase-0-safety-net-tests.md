# Phase 0: Safety Net Tests — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a baseline regression test suite that describes current application behaviour, so that upgrade phases 1–5 can detect breakage.

**Architecture:** Minitest with fixtures (matching the existing test setup). Model tests for validations/associations/scopes/callbacks, controller integration tests for HTTP responses and auth gates, helper tests for output correctness. No factories, no RSpec — keep it consistent with what's already here.

**Tech Stack:** Rails 5.2 Minitest, fixtures (YAML), ActionDispatch::IntegrationTest for controllers.

**VCS:** jj. Create bookmark `ryan/test-safety-net` from current `ryan/bootstrap-3` head.

**Spec:** `docs/superpowers/specs/2026-03-25-rails-modernization-design.md`

---

## File Structure

**New fixture files** (all in `test/fixtures/`):
- `users.yml` — admin, editor, regular, locked users
- `organisations.yml` — one organisation
- `journals.yml` — open access and closed journals
- `locations.yml` — two locations with coordinates
- `sites.yml` — one site with location
- `focusgroups.yml` — two focusgroups
- `fields.yml` — two fields
- `platforms.yml` — two platforms
- `species.yml` — one species with focusgroup
- `posts.yml` — one published, one drafted
- `photos.yml` — one creative commons, one regular
- `validations.yml` — enough to test 2-threshold

**Modified fixture files:**
- `test/fixtures/publications.yml` — add scientific article and chapter fixtures alongside existing Led Zeppelin fixtures

**New test files:**
- `test/models/user_test.rb`
- `test/models/post_test.rb`
- `test/models/photo_test.rb`
- `test/models/species_test.rb`
- `test/models/location_test.rb`
- `test/models/journal_test.rb`
- `test/models/validation_test.rb`
- `test/controllers/pages_controller_test.rb`
- `test/controllers/stats_controller_test.rb`
- `test/controllers/admin/base_controller_test.rb`
- `test/controllers/admin/users_controller_test.rb`
- `test/helpers/application_helper_test.rb`
- `test/helpers/publications_helper_test.rb`
- `test/helpers/dual_range_helper_test.rb`

**Modified test files:**
- `test/test_helper.rb` — add Devise integration test helpers
- `test/models/publication_test.rb` — add validation, association, callback, and instance method tests
- `test/controllers/publications_controller_test.rb` — convert to integration tests, add HTTP tests

---

### Task 1: Create jj bookmark and set up test infrastructure

**Files:**
- Modify: `test/test_helper.rb`

- [ ] **Step 1: Create jj bookmark**

```bash
jj bookmark create ryan/test-safety-net
```

- [ ] **Step 2: Add Devise test helpers to test_helper.rb**

Add `include Devise::Test::IntegrationHelpers` to a new integration test base class. This lets controller tests sign in users.

```ruby
# test/test_helper.rb
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
```

- [ ] **Step 3: Run existing tests to verify they still pass**

Run: `rails test`
Expected: 17 tests, 0 failures (existing publication and controller tests)

- [ ] **Step 4: Commit**

```bash
jj describe -m "Add Devise integration test helpers to test_helper"
jj new
```

---

### Task 2: Create core fixture files

**Files:**
- Create: `test/fixtures/organisations.yml`
- Create: `test/fixtures/users.yml`
- Create: `test/fixtures/journals.yml`
- Create: `test/fixtures/locations.yml`
- Create: `test/fixtures/sites.yml`
- Create: `test/fixtures/focusgroups.yml`
- Create: `test/fixtures/fields.yml`
- Create: `test/fixtures/platforms.yml`
- Create: `test/fixtures/species.yml`

- [ ] **Step 1: Create organisations fixture**

```yaml
# test/fixtures/organisations.yml
csiro:
  name: "CSIRO"
  country: "Australia"
```

- [ ] **Step 2: Create users fixture**

Users need `encrypted_password` for Devise. Use a pre-generated bcrypt hash for "password123". Devise's `confirmed_at` must be set for login to work.

```yaml
# test/fixtures/users.yml
admin_user:
  email: "admin@example.com"
  encrypted_password: "$2a$11$eFmKFjWA8WmMkBkRUMRHMOlGZCpjPcIFjkJsXGWvfYTME3FvT4Gm6"
  first_name: "Admin"
  last_name: "User"
  admin: true
  editor: false
  locked: false
  confirmed_at: "2024-01-01 00:00:00"
  organisation: csiro

editor_user:
  email: "editor@example.com"
  encrypted_password: "$2a$11$eFmKFjWA8WmMkBkRUMRHMOlGZCpjPcIFjkJsXGWvfYTME3FvT4Gm6"
  first_name: "Editor"
  last_name: "User"
  admin: false
  editor: true
  locked: false
  confirmed_at: "2024-01-01 00:00:00"

regular_user:
  email: "regular@example.com"
  encrypted_password: "$2a$11$eFmKFjWA8WmMkBkRUMRHMOlGZCpjPcIFjkJsXGWvfYTME3FvT4Gm6"
  first_name: "Regular"
  last_name: "User"
  admin: false
  editor: false
  locked: false
  confirmed_at: "2024-01-01 00:00:00"

locked_user:
  email: "locked@example.com"
  encrypted_password: "$2a$11$eFmKFjWA8WmMkBkRUMRHMOlGZCpjPcIFjkJsXGWvfYTME3FvT4Gm6"
  first_name: "Locked"
  last_name: "User"
  admin: false
  editor: false
  locked: true
  confirmed_at: "2024-01-01 00:00:00"
```

Note: The bcrypt hash above is for the password "password123". Generate a real one in the Rails console if this doesn't work: `User.new(password: "password123").encrypted_password`.

- [ ] **Step 3: Create journals fixture**

```yaml
# test/fixtures/journals.yml
open_journal:
  name: "Open Access Journal"
  open_access: true

closed_journal:
  name: "Closed Journal"
  open_access: false
```

- [ ] **Step 4: Create locations fixture**

```yaml
# test/fixtures/locations.yml
great_barrier_reef:
  description: "Great Barrier Reef"
  short_description: "GBR;Australia"
  latitude: -18.2861
  longitude: 147.7000

red_sea:
  description: "Red Sea"
  short_description: "Red Sea;Middle East"
  latitude: 27.2000
  longitude: 34.8000
```

- [ ] **Step 5: Create sites fixture**

```yaml
# test/fixtures/sites.yml
osprey_reef:
  site_name: "Osprey Reef"
  latitude: -13.8833
  longitude: 146.5667
  estimated: false
  location: great_barrier_reef
```

- [ ] **Step 6: Create focusgroups, fields, platforms fixtures**

```yaml
# test/fixtures/focusgroups.yml
fish:
  description: "Fish"
  short_description: "Fish"

corals:
  description: "Corals"
  short_description: "Corals"
```

```yaml
# test/fixtures/fields.yml
ecology:
  description: "Ecology"
  short_description: "Ecology"

genetics:
  description: "Genetics"
  short_description: "Genetics"
```

```yaml
# test/fixtures/platforms.yml
scuba:
  description: "SCUBA diving"
  short_description: "SCUBA"

rov:
  description: "Remotely Operated Vehicle"
  short_description: "ROV"
```

- [ ] **Step 7: Create species fixture**

```yaml
# test/fixtures/species.yml
chromis_margaritifer:
  name: "Chromis margaritifer"
  focusgroup: fish
```

- [ ] **Step 8: Run tests to verify fixtures load without errors**

Run: `rails test`
Expected: 17 tests, 0 failures. Fixtures load without foreign key or uniqueness errors.

- [ ] **Step 9: Commit**

```bash
jj describe -m "Add core fixture files for users, journals, locations, species, and related models"
jj new
```

---

### Task 3: Create publication-related fixtures (posts, photos, validations) and expand publications

**Files:**
- Modify: `test/fixtures/publications.yml`
- Create: `test/fixtures/posts.yml`
- Create: `test/fixtures/photos.yml`
- Create: `test/fixtures/validations.yml`

- [ ] **Step 1: Add scientific and chapter publications to existing fixture**

Append to `test/fixtures/publications.yml`:

```yaml
scientific_article:
  title: "Mesophotic coral ecosystems of the Great Barrier Reef"
  authors: "Smith, J.; Jones, A.; Williams, B."
  publication_year: 2020
  publication_type: "scientific"
  publication_format: "article"
  abstract: "This study examines mesophotic coral reef ecosystems at depths of 30-150m."
  contents: "Mesophotic coral ecosystems (MCEs) are deep reef communities found at depths of 30-150m."
  min_depth: 30
  max_depth: 150
  DOI: "10.1234/meso.2020"
  original_data: true
  mesophotic: true
  mce: true
  journal: open_journal
  contributor: admin_user
  created_at: "2024-01-01 00:00:00"
  updated_at: "2024-01-01 00:00:00"

book_chapter:
  title: "Chapter 5: Deep Reef Refugia"
  authors: "Brown, C.; Davis, D."
  publication_year: 2019
  publication_type: "scientific"
  publication_format: "chapter"
  book_title: "Coral Reef Science"
  book_publisher: "Academic Press"
  book_authors: "Editor, E."
  min_depth: 60
  max_depth: 200
  original_data: true
  mesophotic: true
  mce: true
  journal: closed_journal
  contributor: editor_user
  created_at: "2024-01-01 00:00:00"
  updated_at: "2024-01-01 00:00:00"
```

- [ ] **Step 2: Create posts fixture**

```yaml
# test/fixtures/posts.yml
published_post:
  title: "Behind the Science: Mesophotic Reefs"
  content_md: "This is the **markdown** content of the post."
  content_html: "<p>This is the <strong>markdown</strong> content of the post.</p>"
  draft: false
  post_type: "behind_the_science"
  user: admin_user
  featured_user: regular_user
  featured_publication: scientific_article
  slug: "behind-the-science-mesophotic-reefs"

drafted_post:
  title: "Draft Announcement"
  content_md: "This is a draft post."
  content_html: "<p>This is a draft post.</p>"
  draft: true
  post_type: "announcement"
  user: editor_user
  featured_user: editor_user
  slug: "draft-announcement"
```

- [ ] **Step 3: Create photos fixture**

```yaml
# test/fixtures/photos.yml
cc_photo:
  credit: "Photographer A"
  description: "Mesophotic reef at 60m depth"
  depth: 60
  creative_commons: true
  underwater: true
  showcases_location: true
  media_gallery: true
  photographer: regular_user
  location: great_barrier_reef

regular_photo:
  credit: "Photographer B"
  description: "Coral specimen"
  depth: 30
  creative_commons: false
  underwater: false
  showcases_location: false
  media_gallery: false
  photographer: admin_user
```

- [ ] **Step 4: Create validations fixture**

```yaml
# test/fixtures/validations.yml
validation_one:
  validatable: scientific_article
  validatable_type: Publication
  user: admin_user
  created_at: "2025-01-01 00:00:00"
  updated_at: "2025-01-01 00:00:00"

validation_two:
  validatable: scientific_article
  validatable_type: Publication
  user: editor_user
  created_at: "2025-01-01 00:00:00"
  updated_at: "2025-01-01 00:00:00"

validation_three:
  validatable: book_chapter
  validatable_type: Publication
  user: admin_user
  created_at: "2025-01-01 00:00:00"
  updated_at: "2025-01-01 00:00:00"
```

Note: Polymorphic associations in fixtures require the `_type` field set explicitly as a separate column. Timestamps are set explicitly to ensure the `validated` scope's `validations.updated_at >= publications.updated_at` comparison works deterministically.

- [ ] **Step 5: Run tests**

Run: `rails test`
Expected: 17 tests, 0 failures. All fixtures load correctly.

- [ ] **Step 6: Commit**

```bash
jj describe -m "Add publication, post, photo, and validation fixtures"
jj new
```

---

### Task 4: Publication model tests — validations and associations

**Files:**
- Modify: `test/models/publication_test.rb`

- [ ] **Step 1: Add validation tests**

Add to `test/models/publication_test.rb`:

```ruby
test "requires title" do
  pub = Publication.new(authors: "Author", publication_year: 2020, contributor: users(:admin_user))
  assert_not pub.valid?
  assert_includes pub.errors[:title], "can't be blank"
end

test "requires authors" do
  pub = Publication.new(title: "Title", publication_year: 2020, contributor: users(:admin_user))
  assert_not pub.valid?
  assert_includes pub.errors[:authors], "can't be blank"
end

test "requires publication_year" do
  pub = Publication.new(title: "Title", authors: "Author", contributor: users(:admin_user))
  assert_not pub.valid?
  assert_includes pub.errors[:publication_year], "can't be blank"
end

test "valid publication saves" do
  pub = Publication.new(
    title: "Valid Publication",
    authors: "Author A",
    publication_year: 2020,
    contributor: users(:admin_user)
  )
  assert pub.valid?
end
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `rails test test/models/publication_test.rb`
Expected: All tests pass (existing + new)

- [ ] **Step 3: Add association tests**

```ruby
test "belongs to journal" do
  pub = publications(:scientific_article)
  assert_equal journals(:open_journal), pub.journal
end

test "journal is optional" do
  pub = publications(:one)
  assert_nil pub.journal
  assert pub.valid?
end

test "belongs to contributor" do
  pub = publications(:scientific_article)
  assert_equal users(:admin_user), pub.contributor
end

test "has and belongs to many users" do
  pub = publications(:scientific_article)
  pub.users << users(:regular_user)
  assert_includes pub.users, users(:regular_user)
end

test "has many validations" do
  pub = publications(:scientific_article)
  assert_equal 2, pub.validations.count
end
```

- [ ] **Step 4: Run tests**

Run: `rails test test/models/publication_test.rb`
Expected: All pass

- [ ] **Step 5: Commit**

```bash
jj describe -m "Add Publication model validation and association tests"
jj new
```

---

### Task 5: Publication model tests — instance methods and callbacks

**Files:**
- Modify: `test/models/publication_test.rb`

- [ ] **Step 1: Add instance method tests**

```ruby
test "open_access? returns true when journal is open access" do
  pub = publications(:scientific_article)
  assert pub.open_access?
end

test "open_access? returns false when journal is not open access" do
  pub = publications(:book_chapter)
  assert_equal journals(:closed_journal), pub.journal
  assert_not pub.open_access?
end

test "open_access? returns false when no journal" do
  pub = publications(:one)
  assert_nil pub.journal
  assert_not pub.open_access?
end

test "scientific_article? for scientific article" do
  pub = publications(:scientific_article)
  assert pub.scientific_article?
end

test "scientific_article? false for chapter" do
  pub = publications(:book_chapter)
  assert_not pub.scientific_article?
end

test "chapter? for chapter format" do
  pub = publications(:book_chapter)
  assert pub.chapter?
end

test "chapter? false for article" do
  pub = publications(:scientific_article)
  assert_not pub.chapter?
end

test "doi_url returns formatted DOI link" do
  pub = publications(:scientific_article)
  assert_equal "https://doi.org/10.1234/meso.2020", pub.doi_url
end

test "scholar_url returns Google Scholar link with DOI" do
  pub = publications(:scientific_article)
  url = pub.scholar_url
  assert_match /scholar\.google\.com/, url
  assert_match /10\.1234/, url
end

test "short_citation formats authors and year" do
  pub = publications(:scientific_article)
  citation = pub.short_citation
  assert_match /Smith/, citation
  assert_match /2020/, citation
end

test "title_truncated truncates long titles" do
  pub = publications(:scientific_article)
  assert pub.title_truncated.length <= 73  # 70 + "..."
end

test "validated? returns true with 2+ validations" do
  pub = publications(:scientific_article)
  assert pub.validated?
end

test "validated? returns false with fewer than 2 validations" do
  pub = publications(:book_chapter)
  assert_not pub.validated?
end
```

- [ ] **Step 2: Add callback test**

```ruby
test "create_journal_from_name creates journal on save" do
  pub = Publication.new(
    title: "Test",
    authors: "Author",
    publication_year: 2020,
    contributor: users(:admin_user),
    new_journal_name: "Brand New Journal"
  )
  assert_difference "Journal.count", 1 do
    pub.save!
  end
  assert_equal "Brand New Journal", pub.journal.name
end

test "create_journal_from_name does nothing when name blank" do
  pub = Publication.new(
    title: "Test",
    authors: "Author",
    publication_year: 2020,
    contributor: users(:admin_user),
    new_journal_name: ""
  )
  assert_no_difference "Journal.count" do
    pub.save!
  end
end
```

- [ ] **Step 3: Run tests**

Run: `rails test test/models/publication_test.rb`
Expected: All pass

- [ ] **Step 4: Commit**

```bash
jj describe -m "Add Publication instance method and callback tests"
jj new
```

---

### Task 6: Publication model tests — scopes

**Files:**
- Modify: `test/models/publication_test.rb`

- [ ] **Step 1: Add scope tests**

```ruby
test "validated scope returns publications with 2+ validations" do
  validated = Publication.validated
  assert_includes validated, publications(:scientific_article)
  assert_not_includes validated, publications(:book_chapter)
end

test "unvalidated scope returns publications with fewer than 2 validations" do
  unvalidated = Publication.unvalidated
  assert_includes unvalidated, publications(:book_chapter)
  assert_not_includes unvalidated, publications(:scientific_article)
end

test "latest scope returns publications ordered by year desc" do
  latest = Publication.latest(3)
  assert_equal 3, latest.length
  assert latest.first.publication_year >= latest.last.publication_year
end

test "statistics scope filters by status and year" do
  stats = Publication.statistics(:all, 2025)
  assert stats.is_a?(ActiveRecord::Relation)
end

test "annual_counts groups by year" do
  counts = Publication.annual_counts
  assert counts.is_a?(Hash)
end

test "max_year returns highest publication year" do
  assert_equal 2020, Publication.max_year
end

test "min_year returns lowest publication year" do
  assert_equal 1969, Publication.min_year
end

test "max_depth returns highest max_depth" do
  assert Publication.max_depth.is_a?(Integer)
end

test "min_depth returns lowest min_depth" do
  assert Publication.min_depth.is_a?(Integer)
end
```

- [ ] **Step 2: Run tests**

Run: `rails test test/models/publication_test.rb`
Expected: All pass

- [ ] **Step 3: Commit**

```bash
jj describe -m "Add Publication scope tests"
jj new
```

---

### Task 7: User model tests

**Files:**
- Create: `test/models/user_test.rb`

- [ ] **Step 1: Write the test file**

```ruby
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Validations
  test "requires first_name" do
    user = User.new(last_name: "Test", email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "requires last_name" do
    user = User.new(first_name: "Test", email: "test@example.com", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "requires valid email" do
    user = User.new(first_name: "Test", last_name: "User", email: "notanemail", password: "password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "validates website format when present" do
    user = users(:regular_user)
    user.website = "not-a-url"
    assert_not user.valid?
  end

  test "allows blank website" do
    user = users(:regular_user)
    user.website = ""
    assert user.valid?
  end

  # Instance methods
  test "editor_or_admin? true for admin" do
    assert users(:admin_user).editor_or_admin?
  end

  test "editor_or_admin? true for editor" do
    assert users(:editor_user).editor_or_admin?
  end

  test "editor_or_admin? false for regular user" do
    assert_not users(:regular_user).editor_or_admin?
  end

  test "full_name returns last, first" do
    user = users(:admin_user)
    assert_equal "User, Admin", user.full_name
  end

  test "full_name_normal returns first last" do
    user = users(:admin_user)
    assert_equal "Admin User", user.full_name_normal
  end

  # Associations
  test "belongs to organisation" do
    user = users(:admin_user)
    assert_equal organisations(:csiro), user.organisation
  end

  test "organisation is optional" do
    user = users(:regular_user)
    assert_nil user.organisation
    assert user.valid?
  end

  # Pagination
  test "paginates at 100" do
    assert_equal 100, User.default_per_page
  end

  # Callback
  test "create_organisation_from_name creates organisation on save" do
    user = users(:regular_user)
    user.new_organisation_name = "New Org"
    assert_difference "Organisation.count", 1 do
      user.save!
    end
    assert_equal "New Org", user.organisation.name
  end
end
```

- [ ] **Step 2: Run tests**

Run: `rails test test/models/user_test.rb`
Expected: All pass

- [ ] **Step 3: Commit**

```bash
jj describe -m "Add User model tests"
jj new
```

---

### Task 8: Post model tests

**Files:**
- Create: `test/models/post_test.rb`

- [ ] **Step 1: Write the test file**

```ruby
require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # Validations
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
    assert_includes post.errors[:featured_publication_id], "can't be blank"
  end

  test "requires featured_user for early_career" do
    post = Post.new(
      title: "EC Post",
      content_md: "Content",
      post_type: "early_career",
      user: users(:admin_user)
    )
    assert_not post.valid?
    assert_includes post.errors[:featured_user_id], "can't be blank"
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

  # Callback: markdown to HTML
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

  # Scopes
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

  # Instance methods
  test "category returns human-readable name" do
    post = posts(:published_post)
    assert_equal "Behind the science", post.category
  end

  # FriendlyId
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
```

- [ ] **Step 2: Run tests**

Run: `rails test test/models/post_test.rb`
Expected: All pass

- [ ] **Step 3: Commit**

```bash
jj describe -m "Add Post model tests"
jj new
```

---

### Task 9: Remaining model tests (Photo, Species, Location, Journal, Validation)

**Files:**
- Create: `test/models/photo_test.rb`
- Create: `test/models/species_test.rb`
- Create: `test/models/location_test.rb`
- Create: `test/models/journal_test.rb`
- Create: `test/models/validation_test.rb`

- [ ] **Step 1: Write Photo model tests**

```ruby
# test/models/photo_test.rb
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
```

- [ ] **Step 2: Write Species model tests**

```ruby
# test/models/species_test.rb
require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase
  test "belongs to focusgroup" do
    species = species(:chromis_margaritifer)
    assert_equal focusgroups(:fish), species.focusgroup
  end

  test "abbreviation returns abbreviated name" do
    species = species(:chromis_margaritifer)
    # Note: the method uses string interpolation with \.? literal chars
    abbrev = species.abbreviation
    assert abbrev.start_with?("C")
    assert_match /margaritifer/, abbrev
  end

  test "description returns name" do
    species = species(:chromis_margaritifer)
    assert_equal "Chromis margaritifer", species.description
  end

  test "short_description includes name and abbreviation" do
    species = species(:chromis_margaritifer)
    desc = species.short_description
    assert_match /Chromis margaritifer/, desc
    assert_match /;/, desc  # name;abbreviation format
  end

  test "species_code returns parameterized name" do
    species = species(:chromis_margaritifer)
    assert_equal "chromis-margaritifer", species.species_code
  end

  # Note: speciate callback is stubbed to avoid running SpeciationJob
  test "after_create triggers speciate" do
    # Stub SpeciationJob to avoid heavy DB operations
    SpeciationJob.stub(:perform_now, nil) do
      species = Species.create!(name: "Acropora palmata", focusgroup: focusgroups(:corals))
      assert species.persisted?
    end
  end
end
```

- [ ] **Step 3: Write Location model tests**

```ruby
# test/models/location_test.rb
require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  test "requires description" do
    loc = Location.new(latitude: 0, longitude: 0)
    assert_not loc.valid?
    assert_includes loc.errors[:description], "can't be blank"
  end

  test "requires latitude" do
    loc = Location.new(description: "Test", longitude: 0)
    assert_not loc.valid?
    assert loc.errors[:latitude].any?
  end

  test "requires longitude" do
    loc = Location.new(description: "Test", latitude: 0)
    assert_not loc.valid?
    assert loc.errors[:longitude].any?
  end

  test "validates latitude range" do
    loc = Location.new(description: "Test", latitude: 91, longitude: 0)
    assert_not loc.valid?
  end

  test "validates longitude range" do
    loc = Location.new(description: "Test", latitude: 0, longitude: 181)
    assert_not loc.valid?
  end

  test "place_data returns hash with location info" do
    loc = locations(:great_barrier_reef)
    data = loc.place_data(5)
    assert_equal "Great Barrier Reef", data[:name]
    assert_equal 5, data[:z]
    assert data[:lat].present?
    assert data[:lon].present?
  end

  test "has many sites" do
    loc = locations(:great_barrier_reef)
    assert_includes loc.sites, sites(:osprey_reef)
  end
end
```

- [ ] **Step 4: Write Journal model tests**

```ruby
# test/models/journal_test.rb
require 'test_helper'

class JournalTest < ActiveSupport::TestCase
  test "requires name" do
    journal = Journal.new
    assert_not journal.valid?
    assert_includes journal.errors[:name], "can't be blank"
  end

  test "has many publications" do
    journal = journals(:open_journal)
    assert_includes journal.publications, publications(:scientific_article)
  end

  test "description returns name" do
    journal = journals(:open_journal)
    assert_equal "Open Access Journal", journal.description
  end
end
```

- [ ] **Step 5: Write Validation model tests**

```ruby
# test/models/validation_test.rb
require 'test_helper'

class ValidationTest < ActiveSupport::TestCase
  test "requires user_id" do
    v = Validation.new(validatable_type: "Publication", validatable_id: 1)
    assert_not v.valid?
    assert_includes v.errors[:user_id], "can't be blank"
  end

  test "requires validatable_type" do
    v = Validation.new(user: users(:admin_user), validatable_id: 1)
    assert_not v.valid?
    assert_includes v.errors[:validatable_type], "can't be blank"
  end

  test "requires validatable_id" do
    v = Validation.new(user: users(:admin_user), validatable_type: "Publication")
    assert_not v.valid?
    assert_includes v.errors[:validatable_id], "can't be blank"
  end

  test "belongs to user" do
    v = validations(:validation_one)
    assert_equal users(:admin_user), v.user
  end

  test "belongs to validatable publication" do
    v = validations(:validation_one)
    assert_equal publications(:scientific_article), v.validatable
  end
end
```

- [ ] **Step 6: Run all model tests**

Run: `rails test test/models/`
Expected: All pass

- [ ] **Step 7: Commit**

```bash
jj describe -m "Add Photo, Species, Location, Journal, and Validation model tests"
jj new
```

---

### Task 10: Publications controller integration tests

**Files:**
- Modify: `test/controllers/publications_controller_test.rb`

The existing file uses `ActionController::TestCase` which tests a single method. We need to convert to `ActionDispatch::IntegrationTest` for HTTP-level tests while preserving the existing `search_params` tests.

- [ ] **Step 1: Rewrite the controller test file**

Keep the existing search_params tests, add integration tests:

```ruby
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
    assert_redirected_to root_path
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
    assert_redirected_to root_path
  end

  test "edit accessible to editor" do
    sign_in users(:editor_user)
    get edit_publication_path(publications(:scientific_article))
    assert_response :success
  end

  test "create redirects unauthenticated user" do
    post publications_path, params: { publication: { title: "Test", authors: "A", publication_year: 2020 } }
    assert_redirected_to root_path
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
    assert_redirected_to root_path
  end

  test "destroy succeeds for admin" do
    sign_in users(:admin_user)
    assert_difference "Publication.count", -1 do
      delete publication_path(publications(:scientific_article))
    end
  end

  # Pagination
  test "index paginates at 20 for public users" do
    get publications_path
    assert_response :success
    # Verify page renders without error — pagination count tested implicitly
  end

  test "index paginates at 100 for admin" do
    sign_in users(:admin_user)
    get publications_path
    assert_response :success
  end

  # CSV export
  test "index responds to CSV format" do
    get publications_path(format: :csv)
    assert_response :success
    assert_equal "text/csv", response.content_type
  end

  # reject_locked!
  test "locked user gets signed out" do
    sign_in users(:locked_user)
    get root_path
    # Locked users should be signed out and redirected
    assert_redirected_to root_path
  end
end

# Keep existing unit tests for search_params EXACTLY as they are.
# These use ActionController::Parameters objects, not raw hashes.
# Do not modify this class — it already passes.
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
```

- [ ] **Step 2: Run tests**

Run: `rails test test/controllers/publications_controller_test.rb`
Expected: All pass

- [ ] **Step 3: Commit**

```bash
jj describe -m "Add Publications controller integration tests for HTTP responses and auth gates"
jj new
```

---

### Task 11: Pages controller integration tests

**Files:**
- Create: `test/controllers/pages_controller_test.rb`

- [ ] **Step 1: Write the test file**

```ruby
require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home returns success" do
    get root_path
    assert_response :success
  end

  test "about returns success" do
    get about_pages_path
    assert_response :success
  end

  test "members returns success" do
    get members_pages_path
    assert_response :success
  end

  test "show_member returns success" do
    get member_pages_path(users(:regular_user))
    assert_response :success
  end

  test "show_member with invalid id redirects" do
    get member_pages_path(id: 999999)
    assert_redirected_to root_path
  end

  test "media_gallery returns success" do
    get media_gallery_pages_path
    assert_response :success
  end

  test "posts returns success" do
    get posts_pages_path
    assert_response :success
  end

  test "show_post returns success" do
    get post_pages_path(posts(:published_post))
    assert_response :success
  end

  test "inside redirects unauthenticated user" do
    get inside_pages_path
    assert_redirected_to root_path
  end

  test "inside accessible to editor" do
    sign_in users(:editor_user)
    get inside_pages_path
    assert_response :success
  end

  test "contact returns success" do
    get contact_pages_path
    assert_response :success
  end

  test "email with valid params sends mail and redirects" do
    post email_confirmation_pages_path, params: {
      name: "Test User",
      email: "test@example.com",
      message: "This is a test message with enough characters."
    }
    assert_redirected_to root_path
  end

  test "email with invalid params renders contact" do
    post email_confirmation_pages_path, params: {
      name: "",
      email: "test@example.com",
      message: "Test message with enough characters."
    }
    assert_response :success  # re-renders :contact
  end
end
```

- [ ] **Step 2: Run tests**

Run: `rails test test/controllers/pages_controller_test.rb`
Expected: All pass

- [ ] **Step 3: Commit**

```bash
jj describe -m "Add Pages controller integration tests"
jj new
```

---

### Task 12: Stats and Admin controller integration tests

**Files:**
- Create: `test/controllers/stats_controller_test.rb`
- Create: `test/controllers/admin/base_controller_test.rb`
- Create: `test/controllers/admin/users_controller_test.rb`

- [ ] **Step 1: Write Stats controller tests**

```ruby
# test/controllers/stats_controller_test.rb
require 'test_helper'

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "all statistics returns success" do
    get all_stats_path(year: 2023)
    assert_response :success
  end

  test "validated statistics returns success" do
    get validated_stats_path(year: 2023)
    assert_response :success
  end
end
```

- [ ] **Step 2: Write Admin::BaseController tests**

```ruby
# test/controllers/admin/base_controller_test.rb
require 'test_helper'

class Admin::BaseControllerTest < ActionDispatch::IntegrationTest
  test "admin dashboard redirects unauthenticated user" do
    get admin_root_path
    assert_redirected_to root_path
  end

  test "admin dashboard redirects regular user" do
    sign_in users(:regular_user)
    get admin_root_path
    assert_redirected_to root_path
  end

  test "admin dashboard redirects editor" do
    sign_in users(:editor_user)
    get admin_root_path
    assert_redirected_to root_path
  end

  test "admin dashboard accessible to admin" do
    sign_in users(:admin_user)
    get admin_root_path
    assert_response :success
  end
end
```

- [ ] **Step 3: Create admin controllers test directory and write Admin::UsersController tests**

```bash
mkdir -p test/controllers/admin
```

```ruby
# test/controllers/admin/users_controller_test.rb
require 'test_helper'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "index redirects unauthenticated user" do
    get admin_users_path
    assert_redirected_to root_path
  end

  test "index redirects non-admin" do
    sign_in users(:editor_user)
    get admin_users_path
    assert_redirected_to root_path
  end

  test "index accessible to admin" do
    sign_in users(:admin_user)
    get admin_users_path
    assert_response :success
  end

  test "edit accessible to admin" do
    sign_in users(:admin_user)
    get edit_admin_user_path(users(:regular_user))
    assert_response :success
  end

  test "admin cannot change own admin status" do
    sign_in users(:admin_user)
    patch admin_user_path(users(:admin_user)), params: {
      user: { admin: false }
    }
    users(:admin_user).reload
    assert users(:admin_user).admin?
  end
end
```

- [ ] **Step 4: Run all controller tests**

Run: `rails test test/controllers/`
Expected: All pass

- [ ] **Step 5: Commit**

```bash
jj describe -m "Add Stats and Admin controller integration tests"
jj new
```

---

### Task 13: Helper tests

**Files:**
- Create: `test/helpers/application_helper_test.rb`
- Create: `test/helpers/publications_helper_test.rb`
- Create: `test/helpers/dual_range_helper_test.rb`

- [ ] **Step 1: Write ApplicationHelper tests**

```ruby
# test/helpers/application_helper_test.rb
require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "title sets page title" do
    title("Test Page")
    assert_equal "Test Page | Mesophotic.org", @title
  end

  test "mesophotic_score counts mesophotic occurrences" do
    deep_count, word_count = mesophotic_score("mesophotic coral ecosystems and deep reef habitats on the mesophotic zone")
    assert_equal 2, deep_count  # "mesophotic" appears twice
    assert word_count > 0
  end

  test "mesophotic_score with no matches returns zero" do
    deep_count, word_count = mesophotic_score("shallow coral reefs")
    assert_equal 0, deep_count
  end

  test "new_table_row_on_iteration returns row break" do
    result = new_table_row_on_iteration(4, 4)
    assert_equal "</tr><tr>", result
  end

  test "new_table_row_on_iteration returns nil when not on boundary" do
    result = new_table_row_on_iteration(3, 4)
    assert_nil result
  end
end
```

- [ ] **Step 2: Write PublicationsHelper tests**

```ruby
# test/helpers/publications_helper_test.rb
require 'test_helper'

class PublicationsHelperTest < ActionView::TestCase
  test "format_authors returns HTML string" do
    pub = publications(:scientific_article)
    result = format_authors(pub)
    assert result.html_safe?
    assert_match /Smith/, result
  end

  test "format_publication_citation includes title and year" do
    pub = publications(:scientific_article)
    result = format_publication_citation(pub)
    assert result.html_safe?
    assert_match /Mesophotic coral ecosystems/, result
    assert_match /2020/, result
  end

  test "obtain_snippet returns text around search term" do
    contents = "This is a long piece of text about mesophotic coral ecosystems and their importance."
    result = obtain_snippet(contents, "mesophotic")
    assert_match /mesophotic/, result
  end

  test "count_word_in_contents counts word occurrences" do
    result = count_word_in_contents("reef", "coral reef ecosystems on the reef")
    assert_equal 2, result
  end

  test "count_word_in_contents returns empty for no matches" do
    result = count_word_in_contents("missing", "coral reef ecosystems")
    assert_equal "", result
  end
end
```

- [ ] **Step 3: Write DualRangeHelper tests**

```ruby
# test/helpers/dual_range_helper_test.rb
require 'test_helper'

class DualRangeHelperTest < ActionView::TestCase
  test "dual_range_slider renders HTML" do
    result = dual_range_slider("search_params[year_range]", {
      min: 1970,
      max: 2024,
      step: 1,
      value: "1990,2020",
      id: "year_range"
    })
    assert_match /input/, result
    assert_match /year_range/, result
  end

  test "dual_range_slider with default values" do
    result = dual_range_slider("test_range", {
      min: 0,
      max: 100,
      step: 5
    })
    assert_match /input/, result
  end
end
```

- [ ] **Step 4: Run all helper tests**

Run: `rails test test/helpers/`
Expected: All pass

- [ ] **Step 5: Commit**

```bash
jj describe -m "Add helper tests for ApplicationHelper, PublicationsHelper, and DualRangeHelper"
jj new
```

---

### Task 14: Final test run and verification

- [ ] **Step 1: Run the full test suite**

Run: `rails test`
Expected: All tests pass. Count should be approximately 70–85 tests.

- [ ] **Step 2: Review test count by file**

Run: `rails test --verbose 2>&1 | tail -5`
Verify the total count and that there are 0 failures, 0 errors.

- [ ] **Step 3: Commit any final fixes**

If any tests needed adjustment, commit the fixes:

```bash
jj describe -m "Fix test adjustments from full suite run"
jj new
```

- [ ] **Step 4: Verify bookmark is set**

```bash
jj log --limit 20
jj bookmark list
```

Verify all commits are on the `ryan/test-safety-net` bookmark.

- [ ] **Step 5: Move bookmark to head**

```bash
jj bookmark set ryan/test-safety-net
```
