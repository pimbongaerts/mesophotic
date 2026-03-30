# Mesophotic.org Modernization Design

**Date:** 2026-03-25
**Goal:** Bring the application from Rails 5.2 / Ruby 2.7 / Bootstrap 3 to Rails 7.1 / Ruby 3.2 / Bootstrap 5, with a baseline test suite as a safety net.

## Current State

- **Rails** 5.2.8, **Ruby** 2.7, **Bootstrap** 3.4.1 (via `bootstrap-sass` gem)
- **Frontend:** Sprockets, jQuery, CoffeeScript, Turbolinks, SCSS
- **Database:** SQLite3 (all environments)
- **Test coverage:** ~3.8% — 17 tests across 2 files (Publication model search scopes, PublicationsController `search_params` helper)
- **Dev environment:** Nix flake + direnv
- **VCS:** jj (colocated with git)
- **Models:** 22, **Controllers:** 23, **Views:** 171 ERB files
- **Custom component:** Dual range slider in `app/helpers/dual_range_helper.rb`, `app/views/shared/_dual_range_slider.html.erb`, `app/assets/javascripts/dual_range.js`, and inline SCSS (recent replacement for `bootstrap-rails-slider` gem)

## Principles

- **Incremental:** Each phase is a separate jj bookmark, building on the last.
- **Small commits:** Each commit is self-contained, reversible, and reviewable. One logical change per commit. The app should be in a working state after every commit.
- **Test-first:** Baseline tests written before any changes to catch regressions.
- **Tight scope:** Only change what's required for the target upgrade. Don't modernize what still works.

## Phase 0: Safety Net Tests

**Bookmark:** `ryan/test-safety-net`
**Purpose:** Establish regression tests that describe current behaviour before any changes.

### Model Tests

Priority models (those with real logic beyond simple associations):

| Model | What to test |
|-------|-------------|
| Publication | Validations (required: title, authors, year). Associations (journal, users, platforms, fields, focusgroups, locations, sites, species). Callbacks (`before_save :create_journal_from_name`). Instance methods (`open_access?`, `scientific_article?`, `chapter?`, `doi_url`, `scholar_url`, `short_citation`). Scopes (`validated`, `unvalidated`, `expired`, `latest`, `statistics`). CSV export. Existing search tests already cover `search`, `sift`, `relevance`, `depth_search`. |
| User | Validations (Devise fields). Associations (organisation, publications, platforms, photos). Role methods (admin/editor checks). `paginates_per 100`. |
| Post | Validations. Markdown-to-HTML conversion (`before_save`). FriendlyId slug generation. Scopes (`published`, `drafted`). Polymorphic `postable` association. |
| Photo | Validations. Associations (photographer, location, site, expedition, etc.). Scopes (`media_gallery`, `showcases_location`). |
| Species | Associations (focusgroup, observations, publications). `after_create` speciation callback (note: runs `SpeciationJob.perform_now` which is heavy — stub this in tests). Abbreviation generation. |
| Location | `place_data` method for map rendering. `published` scope. |
| Journal | `open_access` flag. Association with publications. |
| Validation (model) | Polymorphic validatable. The 2-validation-threshold logic. |

### Controller Integration Tests

| Controller | What to test |
|-----------|-------------|
| PublicationsController | `index` (with and without search params, pagination, CSV export). `show`. Auth gates on `new`, `create`, `edit`, `update`, `destroy`. Validation add/remove/touch actions. |
| PagesController | `home`, `about`, `members`, `show_member`, `media_gallery`, `contact`/`email`. |
| StatsController | `all` and `validated` with year param. Key chart endpoints return 200. |
| Admin::* | Auth gate — unauthenticated users get redirected. Admin users can access dashboard. |
| ApplicationController | `require_admin!` and `require_admin_or_editor!` helpers (note: `require_admin_or_editor!` uses `@current_user` instead of `current_user` — verify this works consistently). `reject_locked!` behaviour. |

### Helper Tests

| Helper | What to test |
|--------|-------------|
| ApplicationHelper | `linkify`, `mesophotic_score`, `word_association`, `species_association`. |
| PublicationsHelper | `format_authors`, `format_publication_citation`, `search_param`. |
| DualRangeHelper | `dual_range_slider` generates correct HTML structure with expected IDs and values. |

### Fixtures

Expand from the current 3 publication fixtures to cover:
- Users (admin, editor, regular, locked)
- Publications (with various types, depths, years, associations)
- Journals (open access and not)
- Locations, Sites, Species, Focusgroups, Fields, Platforms
- Posts (published and drafted, different types)
- Photos (with and without creative commons)
- Validations (enough to test the 2-threshold)

**Target:** ~60–80 tests covering critical paths. Not exhaustive — just enough that a broken upgrade shows up as a test failure.

## Phase 1: Bootstrap 3 → 5

**Bookmark:** `ryan/bootstrap-5`
**Parent:** `ryan/test-safety-net`

### Gem Changes

- Remove: `bootstrap-sass` (~3.4.1), `sass` (deprecated Ruby Sass gem — unused, `sass-rails` delegates to `sassc` internally)
- Add: `bootstrap` (~5.3)
- May need: `sassc-rails` or update sass compilation pipeline

### SCSS Migration

`railsbricks_custom.scss` is the primary file. Key changes:

**Critical: File restructuring required.** Currently `@import "bootstrap"` is at the top of the file (line 2), before all variable overrides. In Bootstrap 3's `bootstrap-sass`, this happened to work. In Bootstrap 5, variables use `!default` flags and **must be declared before the `@import "bootstrap"` line** or they will be silently ignored. The file must be restructured to: variable overrides first, then `@import "bootstrap"`.

**Variable name changes:**

| Bootstrap 3 | Bootstrap 5 |
|-------------|-------------|
| `$brand-primary`, `$brand-success`, etc. | `$primary`, `$success`, etc. |
| `@import "bootstrap"` (from bootstrap-sass) | `@import "bootstrap"` (from bootstrap gem, different path) |
| Panel variables | Card variables |
| Navbar variables (`$navbar-default-*`) | Navbar variables (`$navbar-light-*` or `$navbar-dark-*`) |
| `$btn-default-*` | `$btn-secondary-*` (no "default" variant in BS5) |
| `$font-size-base: 14px` | `$font-size-base: 0.875rem` (BS5 uses `rem` units — `14px` will compile but causes calculation issues in BS5's `rem`-based math) |

**SCSS `@extend` breakage:** `railsbricks_custom.scss` uses `@extend .img-responsive` which will cause a Sass **compilation error** — Bootstrap 5 renamed this to `.img-fluid`. This is not just a visual bug; the build will fail.

### View Class Migration

Commits grouped by component type:

1. **Navbar:** `navbar-default` → `navbar-light bg-light`. `navbar-fixed-top` → `fixed-top`. `navbar-toggle` → `navbar-toggler`. `icon-bar` spans → `navbar-toggler-icon`. `navbar-right` → `ms-auto`.
2. **Panels → Cards:** `panel` → `card`. `panel-heading` → `card-header`. `panel-body` → `card-body`. `panel-footer` → `card-footer`. `panel-default` → (just `card`).
3. **Grid:** `col-xs-*` → `col-*`. `col-*-offset-*` → `offset-*-*`.
4. **Responsive utilities:** `hidden-xs` → `d-none d-sm-block`. `hidden-sm hidden-md` → appropriate `d-*-none d-*-block` combos.
5. **Forms:** `form-group` → `mb-3` (removed in BS5, use margin utilities). `form-horizontal` → removed (use grid directly). `form-inline` → removed (use flex utilities). `control-label` → `form-label`. `help-block` → `form-text`. ~136 occurrences across 21 view files including Devise, publication, admin, and contact forms.
6. **Data attributes:** `data-toggle` → `data-bs-toggle`. `data-dismiss` → `data-bs-dismiss`. `data-target` → `data-bs-target`. `data-parent` → `data-bs-parent`.
7. **Buttons:** `btn-default` → `btn-secondary`. Verify `btn-basic` custom class still works.
8. **Labels → Badges:** BS3 `label label-success`, `label-info`, `label-primary`, `label-warning`, `label-danger` → BS5 `badge bg-success`, `badge bg-info`, etc. (~10 occurrences in publication validation views). The `label` component was removed in BS5; all become badges.
9. **Badges:** Existing bare `badge` class → `badge bg-secondary` (BS5 badges have no default background — contextual class required). ~14 view files affected.
10. **Misc:** `caret` class (remove — BS5 dropdowns handle this with CSS). `sr-only` → `visually-hidden`.

### JavaScript

- Bootstrap 5 JS no longer requires jQuery. But we keep jQuery for now (the app uses it elsewhere).
- Update `application.js` — the `bootstrap` require may need to change depending on how the new gem exposes JS.
- Verify collapse, dropdown, and alert dismiss still work.

### Dual Range Slider

- Already uses BS5-compatible colours (#0d6efd). Likely needs no changes.
- Verify it still renders and functions after Bootstrap 5 CSS is loaded.
- Fix any z-index or layout issues from Bootstrap 5's different base styles.

### Kaminari

- No custom Kaminari views exist (no `app/views/kaminari/` directory). Kaminari uses its default theme.
- Generate Bootstrap 5-compatible views: `rails g kaminari:views bootstrap5`.

### Devise Views

- Devise views in `app/views/devise/` use Bootstrap form classes (`form-group`, `control-label`, etc.). These need the same form class migration as step 5 above.

## Phase 2: Rails 5.2 → 6.0

**Bookmark:** `ryan/rails-6.0`
**Parent:** `ryan/bootstrap-5`
**Ruby:** 2.7 (no change)

### Key Changes

- **Zeitwerk autoloader:** Replace classic autoloader. Run `bin/rails zeitwerk:check` to identify issues. Most common problem: files that don't match the expected naming convention.
- **Zeitwerk hazard — class-level DB queries:** `Publication` model has constants (`PUBLICATION_CHARACTERISTICS`, `PUBLICATION_LOCATIONS`, `PUBLICATION_FOCUSGROUPS`, `PUBLICATION_PLATFORMS`, `PUBLICATION_FIELDS`) that execute database queries at class load time. Under Zeitwerk's lazy loading, if `Publication` is loaded before the database is ready (during `db:migrate`, `assets:precompile`, etc.), these will raise errors. Fix: convert to class methods with memoization.
- **`jquery_ujs` → `rails-ujs`:** Rails 5.1+ ships `rails-ujs` as the default UJS driver. While `jquery_ujs` still works on Rails 6, it will be dropped in Rails 7. Begin the transition here: replace `//= require jquery_ujs` with `//= require rails-ujs` in `application.js`. This affects `data-method`, `data-confirm`, and `data-remote` attributes in views (should work identically).
- **`config/application.rb`:** Update `config.load_defaults` from `5.2` to `6.0`.
- **`rails app:update`:** Generate config diffs and resolve each one.
- **Credentials:** Rails 6 encourages `credentials.yml.enc` over Figaro. No need to migrate immediately — Figaro still works.
- **Action Text / Action Mailbox:** New frameworks, but optional. Don't add unless needed.
- **Active Storage:** Direct upload support improved. Existing setup should work.

### Gem Compatibility

| Gem | Action needed |
|-----|--------------|
| `coffee-rails` | Still works on Rails 6.0 but deprecated. Keep for now. |
| `turbolinks` | Still works. Keep. |
| `rails_admin` | Verify version supports Rails 6. May need bump. |
| `paper_trail` | Verify version. May need bump. |
| `acts_as_textcaptcha` | Check maintenance status. May need fork or replacement. |
| `switch_user` | Check compatibility. |
| `render_async` | Check compatibility. |
| `aws-sessionstore-dynamodb` | Check compatibility. |

### Nix Flake

- Ruby 2.7 stays the same.
- Bundler version may need updating if new gems require it.
- Run `bundle lock && bundix` after Gemfile changes.

## Phase 3: Rails 6.0 → 6.1

**Bookmark:** `ryan/rails-6.1`
**Parent:** `ryan/rails-6.0`
**Ruby:** 2.7 (no change)

### Key Changes

- Mostly additive: `where.associated`, `destroy_async`, strict loading.
- `config.load_defaults '6.1'`.
- `rails app:update` — resolve config diffs.
- Fix any deprecation warnings introduced in 6.0.
- `ActiveRecord::Base` → may see deprecation warnings about `connection` usage.
- **Remove `represent_boolean_as_integer`:** The config line `config.active_record.sqlite3.represent_boolean_as_integer = true` in `config/application.rb` was deprecated in Rails 6.0 and **removed in Rails 6.1** — it will cause a startup error if not deleted.
- **Verify boolean scopes:** The `Post` model uses raw SQL boolean comparisons (`where("draft = 0 OR draft = 'f'")`). After removing the boolean config, verify these still work. Ideally convert to `where(draft: false)` / `where(draft: true)`.

This is expected to be a smooth step aside from the boolean config removal.

## Phase 4: Ruby 3.2 + Rails 7.0

**Bookmark:** `ryan/rails-7.0`
**Parent:** `ryan/rails-6.1`

This is the riskiest phase. It combines a Ruby major version upgrade with a Rails major version upgrade. To keep commits bisectable, work in this order:

### 4a: Ruby 2.7 → 3.2 (on Rails 6.1)

- Update `.ruby-version` to `3.2`.
- Update Nix flake: change Ruby overlay version.
- Update Bundler version if needed.
- Run `bundle lock && bundix`.
- **Keyword arguments:** Ruby 3 is strict. `method(opts)` where `opts` is a hash no longer auto-splats into keyword args. Grep for patterns like `method(**options)` and hash-to-kwargs calls.
- **Frozen string literals:** Not enforced by default but good to note.
- Run full test suite. Fix all failures before proceeding.

### 4b: CoffeeScript Removal (on Rails 6.1 + Ruby 3.2)

- `coffee-rails` doesn't work well on Rails 7. Remove it now while the rest of the stack is stable.
- Currently `analytics.js.coffee` exists but is commented out in `application.js`. Delete it.
- Audit for any other CoffeeScript files.
- Remove `coffee-rails` from Gemfile.

### 4c: Rails 6.1 → 7.0

- `config.load_defaults '7.0'`.
- `rails app:update` — resolve config diffs.
- `button_to` default method changes from POST to PATCH in some contexts — audit forms.
- `Rails.application.credentials` changes — verify Figaro still works.

### 4d: `rails_admin` 2.x → 3.x

- `rails_admin` 2.3.1 has a hard dependency of `rails (>= 5.0, < 7)`. It **will not install** on Rails 7.
- `rails_admin` 3.x is a major rewrite: drops `haml`, `jquery-ui-rails`, `nested_form`, `rack-pjax`, and `remotipart` as dependencies.
- The `config/initializers/rails_admin.rb` configuration API changes. Review and update.
- Test the admin interface manually after upgrade.

### 4e: Turbolinks → Turbo

- Remove `turbolinks` gem, add `turbo-rails`.
- Or: use `turbolinks` compatibility shim if Turbo migration is too disruptive.
- `Turbolinks.visit()` → `Turbo.visit()`. `data-turbolinks-*` → `data-turbo-*`.
- The app's JavaScript is relatively simple so this should be manageable.

## Phase 5: Rails 7.0 → 7.1

**Bookmark:** `ryan/rails-7.1`
**Parent:** `ryan/rails-7.0`

### Key Changes

- Mostly additive: async queries, `normalizes`, Trilogy adapter, BYO auth generator.
- `config.load_defaults '7.1'`.
- `rails app:update`.
- Verify all tests pass.
- This should be the smoothest upgrade step.

## Phase 6: Feature Work

**Bookmark:** `ryan/features`
**Parent:** `ryan/rails-7.1`
**Purpose:** Planned feature additions that were deferred until the modernization is complete.

### 6a: Fix Textcaptcha

The `acts_as_textcaptcha` gem's external API returns nil questions — `User.new.textcaptcha_question` returns `nil`. The sign-up form shows "Answer the following question, to prove you're not a robot." but no actual question appears.

**Options (evaluate in order):**
1. Replace with a simple custom captcha (lowest dependency risk)
2. Replace with reCAPTCHA or similar maintained service
3. Fix the API key if the textcaptcha service is still operational

**Note:** If `acts_as_textcaptcha` doesn't support Rails 7 (flagged in Risk Notes), this must be addressed during Phase 4 instead. Check compatibility before proceeding.

### 6b: Bluesky Feed

Add a Bluesky `#mesophotic` feed alongside the existing Mastodon feed on the home page.

- Bluesky public API: `public.api.bsky.app/xrpc/app.bsky.feed.searchPosts?q=%23mesophotic`
- Add Bluesky logo next to Mastodon logo in the card header
- Logos act as tab selectors — selected logo coloured, unselected muted
- Switch feed content based on selected tab
- Fetch profile pics/names async similar to existing Mastodon implementation

### 6c: Threads Feed

Add a Threads `#mesophotic` feed alongside the Mastodon and Bluesky feeds on the home page.

- Investigate Threads API availability (Meta's Threads API may require app review/approval)
- Add Threads logo to the tab selector in the card header alongside Mastodon and Bluesky
- Same tabbed selection pattern — selected logo coloured, unselected muted
- Fetch and display posts async similar to Mastodon and Bluesky implementations

### 6d: Multiple Social Media Handles

Allow users to specify multiple social handles (Mastodon, BlueSky, Threads, Twitter/X) instead of the single `twitter` field.

- Add a `social_links` table or JSON column to store multiple handles per user
- Each link has a platform (mastodon, bluesky, threads, twitter) and a handle/URL
- Update edit profile form to allow adding/removing social links
- Update member profile page to show all social icons
- Update the `contact_links` partial to render platform-specific icons (bi-mastodon, bi-twitter-x, custom SVG for BlueSky/Threads)

### 6e: User Role Consolidation

Replace the independent `admin` and `editor` boolean columns with a single `role` string column (`member`, `editor`, `admin`) where admin is a strict superset of editor.

- Add migration: add `role` column (default `"member"`), populate from existing booleans, remove `admin` and `editor` columns
- Update `User` model: `admin?` checks `role == "admin"`, `editor?` checks `role.in?(["editor", "admin"])`
- Simplify `require_admin_or_editor!` to just check `editor?` (which now inherently includes admins)
- Update all views: admin user edit form (single role dropdown instead of two checkboxes), badges, profile forms
- Update fixtures and tests

### 6f: Breadcrumb Navigation

Replace the `<<< Back` links throughout the app with proper breadcrumb navigation using Bootstrap 5's breadcrumb component.

- Create a shared breadcrumb partial that accepts a trail of label/path pairs
- Replace `_page_title.html.erb` back link with breadcrumbs (e.g. Home > Publications > "Paper Title")
- Replace all admin `<<< Back` links with breadcrumbs (e.g. Home > Admin > Users > Edit)
- Replace summary page back links with breadcrumbs (e.g. Home > Locations > "American Samoa")
- Handle dynamic titles (publication names, location names, user emails)

## Future Phases (Out of Scope)

These are noted for future planning but not part of this effort:

### Performance
- **N+1 queries in format_authors:** `publications_helper.rb` iterates `publication.users` for every publication in collection views. Fix with eager loading (`Publication.includes(:users)`) in controllers.
- **word_association / species_association helper:** `application_helper.rb` loads ALL platforms, fields, focusgroups, locations, and species into memory every time it's called (per publication view). Cache per request or memoize.
- **CSV export memory:** `Publication#to_csv` builds large in-memory hashes for all associations before generating CSV. Consider streaming.
- **ResizeObserver cleanup:** `charts.js` creates ResizeObservers for wordclouds that may not be fully garbage collected on Turbolinks navigation. Add cleanup on `turbolinks:before-cache`.
- **MiniMagick → VIPS:** Switch Active Storage variant processor from MiniMagick (loads full image into memory) to VIPS (streams, much lower memory). Requires installing `libvips` on dev (Nix flake) and production (Dreamhost VPS). `ruby-vips` gem is already in the bundle.

### Technical Modernization
- **jQuery → vanilla JS / Stimulus:** Replace jQuery DOM manipulation and AJAX with Stimulus controllers and `fetch()`.
- **Sprockets → Propshaft or importmap-rails:** Modernize the asset pipeline.
- **`owlcarousel-rails` → modern alternative:** The gem is unmaintained. Replace with a vanilla JS carousel or CSS-only solution.
- **`nested_form` / `remotipart` → Turbo Streams:** Replace legacy remote form gems with Hotwire patterns.
- **System tests:** Add Capybara-based browser tests for full user flow coverage.
- **Ruby 3.3+, Rails 7.2 / 8.0:** Continue the upgrade path.
- **HABTM → `has_many :through`:** Convert join tables for better auditability and flexibility.
- **Figaro → Rails credentials:** Migrate environment variable management.

## Risk Notes

- **`bootstrap-sass` → `bootstrap` gem:** The SCSS import paths change completely. This will touch every stylesheet. The file structure of `railsbricks_custom.scss` must be restructured (variables before imports).
- **SCSS compilation errors:** `@extend .img-responsive` will cause a build failure (BS5 renames to `.img-fluid`). Must be caught before the form class migration.
- **Form class volume:** ~136 form class occurrences across 21 view files. This is the most tedious part of the Bootstrap migration.
- **Zeitwerk (Rails 6.0):** If any models/controllers don't follow naming conventions, autoloading will break. `bin/rails zeitwerk:check` is the diagnostic tool. The `Publication` model's class-level DB queries are a known hazard.
- **`represent_boolean_as_integer` (Rails 6.1):** Must be removed before upgrading to 6.1 or the app won't start.
- **Ruby 3.2 kwargs:** This is historically the most labor-intensive part of a Ruby 2 → 3 migration. The test suite from Phase 0 is critical here.
- **`rails_admin` 3.x (Rails 7.0):** Major rewrite required. Config API changes, transitive dependencies removed. Cannot be deferred — `rails_admin` 2.x won't install on Rails 7.
- **`acts_as_textcaptcha`:** This gem may be abandoned. If it doesn't support Rails 7, we'll need to fork it or replace it with a simple custom implementation.
- **SQLite3 gem:** Version constraints may shift. The `~> 1.6.9` pin may need updating.
- **`owlcarousel-rails`:** Currently commented out in `application.js` and `application.scss`. Not actively breaking anything, but if re-enabled it may conflict with BS5 styles.
