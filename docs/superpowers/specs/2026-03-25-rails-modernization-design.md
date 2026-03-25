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
- **Custom engine:** `engines/dual_range_slider/` (recent replacement for `bootstrap-rails-slider` gem)

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
| Species | Associations (focusgroup, observations, publications). `after_create` speciation callback. Abbreviation generation. |
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
| ApplicationController | `require_admin!` and `require_admin_or_editor!` helpers. `reject_locked!` behaviour. |

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

- Remove: `bootstrap-sass` (~3.4.1)
- Add: `bootstrap` (~5.3)
- May need: `sassc-rails` or update sass compilation pipeline

### SCSS Migration

`railsbricks_custom.scss` is the primary file. Key changes:

| Bootstrap 3 | Bootstrap 5 |
|-------------|-------------|
| `$brand-primary`, `$brand-success`, etc. | `$primary`, `$success`, etc. |
| `@import "bootstrap"` (from bootstrap-sass) | `@import "bootstrap"` (from bootstrap gem, different path) |
| Panel variables | Card variables |
| Navbar variables (`$navbar-default-*`) | Navbar variables (`$navbar-light-*` or `$navbar-dark-*`) |
| `$btn-default-*` | `$btn-secondary-*` (no "default" variant in BS5) |

### View Class Migration

Commits grouped by component type:

1. **Navbar:** `navbar-default` → `navbar-light bg-light`. `navbar-toggle` → `navbar-toggler`. `icon-bar` spans → `navbar-toggler-icon`. `navbar-right` → `ms-auto`.
2. **Panels → Cards:** `panel` → `card`. `panel-heading` → `card-header`. `panel-body` → `card-body`. `panel-footer` → `card-footer`. `panel-default` → (just `card`).
3. **Grid:** `col-xs-*` → `col-*`. `col-*-offset-*` → `offset-*-*`.
4. **Responsive utilities:** `hidden-xs` → `d-none d-sm-block`. `hidden-sm hidden-md` → appropriate `d-*-none d-*-block` combos.
5. **Data attributes:** `data-toggle` → `data-bs-toggle`. `data-dismiss` → `data-bs-dismiss`. `data-target` → `data-bs-target`. `data-parent` → `data-bs-parent`.
6. **Buttons:** `btn-default` → `btn-secondary`. Verify `btn-basic` custom class still works.
7. **Badges:** `badge` → `badge bg-secondary` (or appropriate contextual class).
8. **Misc:** `caret` class (remove — BS5 dropdowns handle this with CSS). `sr-only` → `visually-hidden`.

### JavaScript

- Bootstrap 5 JS no longer requires jQuery. But we keep jQuery for now (the app uses it elsewhere).
- Update `application.js` — the `bootstrap` require may need to change depending on how the new gem exposes JS.
- Verify collapse, dropdown, and alert dismiss still work.

### Dual Range Slider

- Already uses BS5-compatible colours (#0d6efd). Likely needs no changes.
- Verify it still renders and functions after Bootstrap 5 CSS is loaded.
- Fix any z-index or layout issues from Bootstrap 5's different base styles.

### Kaminari

- Check if kaminari pagination templates use Bootstrap 3 classes. If so, regenerate with `rails g kaminari:views bootstrap5` or equivalent.

### Devise Views

- Devise views in `app/views/devise/` use Bootstrap form classes. Verify they still render correctly.

## Phase 2: Rails 5.2 → 6.0

**Bookmark:** `ryan/rails-6.0`
**Parent:** `ryan/bootstrap-5`
**Ruby:** 2.7 (no change)

### Key Changes

- **Zeitwerk autoloader:** Replace classic autoloader. Run `bin/rails zeitwerk:check` to identify issues. Most common problem: files that don't match the expected naming convention.
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

This is expected to be the smoothest step.

## Phase 4: Rails 6.1 → 7.0 + Ruby 3.2

**Bookmark:** `ryan/rails-7.0`
**Parent:** `ryan/rails-6.1`

### Ruby 2.7 → 3.2

- Update `.ruby-version` to `3.2`.
- Update Nix flake: change Ruby overlay version.
- **Keyword arguments:** Ruby 3 is strict. `method(opts)` where `opts` is a hash no longer auto-splats into keyword args. Grep for patterns like `method(**options)` and hash-to-kwargs calls.
- **Frozen string literals:** Not enforced by default but good to note.
- Run full test suite after Ruby upgrade, before Rails upgrade.

### CoffeeScript Removal

- `coffee-rails` doesn't work well on Rails 7. Convert any `.coffee` files to `.js`.
- Currently `analytics.js.coffee` exists but is commented out in `application.js`. Can likely just delete it.
- Audit for any other CoffeeScript files.

### Turbolinks → Turbo

- Remove `turbolinks` gem, add `turbo-rails`.
- Or: use `turbolinks` compatibility shim if Turbo migration is too disruptive.
- `Turbolinks.visit()` → `Turbo.visit()`. `data-turbolinks-*` → `data-turbo-*`.
- The app's JavaScript is relatively simple so this should be manageable.

### Other

- `config.load_defaults '7.0'`.
- `rails app:update`.
- `button_to` default method changes from POST to PATCH in some contexts — audit forms.
- `Rails.application.credentials` changes — verify Figaro still works.

## Phase 5: Rails 7.0 → 7.1

**Bookmark:** `ryan/rails-7.1`
**Parent:** `ryan/rails-7.0`

### Key Changes

- Mostly additive: async queries, `normalizes`, Trilogy adapter, BYO auth generator.
- `config.load_defaults '7.1'`.
- `rails app:update`.
- Verify all tests pass.
- This should be the smoothest upgrade step.

## Future Phases (Out of Scope)

These are noted for future planning but not part of this modernization effort:

- **jQuery → vanilla JS / Stimulus:** Replace jQuery DOM manipulation and AJAX with Stimulus controllers and `fetch()`.
- **Sprockets → Propshaft or importmap-rails:** Modernize the asset pipeline.
- **`owlcarousel-rails` → modern alternative:** The gem is unmaintained. Replace with a vanilla JS carousel or CSS-only solution.
- **`nested_form` / `remotipart` → Turbo Streams:** Replace legacy remote form gems with Hotwire patterns.
- **System tests:** Add Capybara-based browser tests for full user flow coverage.
- **Ruby 3.3+, Rails 7.2 / 8.0:** Continue the upgrade path.
- **HABTM → `has_many :through`:** Convert join tables for better auditability and flexibility.
- **Figaro → Rails credentials:** Migrate environment variable management.

## Risk Notes

- **`bootstrap-sass` → `bootstrap` gem:** The SCSS import paths change completely. This will touch every stylesheet.
- **Zeitwerk (Rails 6.0):** If any models/controllers don't follow naming conventions, autoloading will break. `bin/rails zeitwerk:check` is the diagnostic tool.
- **Ruby 3.2 kwargs:** This is historically the most labor-intensive part of a Ruby 2 → 3 migration. The test suite from Phase 0 is critical here.
- **`acts_as_textcaptcha`:** This gem may be abandoned. If it doesn't support Rails 7, we'll need to fork it or replace it with a simple custom implementation.
- **`rails_admin`:** Major version bumps between Rails 5 and 7. UI may change. Test the admin interface manually at each step.
- **SQLite3 gem:** Version constraints may shift. The `~> 1.6.9` pin may need updating.
