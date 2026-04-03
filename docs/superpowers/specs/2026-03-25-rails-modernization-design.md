# Mesophotic.org Modernization Design

**Date:** 2026-03-25 (last updated 2026-04-03)
**Goal:** Bring the application from Rails 5.2 / Ruby 2.7 / Bootstrap 3 to Rails 8.1 / Ruby 3.4, with a baseline test suite as a safety net.

## Current State

- **Rails** 6.1, **Ruby** 3.2, **Bootstrap** 5.3 (via `bootstrap` gem)
- **Frontend:** Sprockets, Bootstrap Icons 1.13.1, vanilla JS + jQuery, Turbolinks, SCSS
- **Database:** SQLite3 (all environments)
- **Auth:** Devise with Cloudflare Turnstile CAPTCHA on registration
- **Admin:** rails_admin (mounted at `/admin/db`)
- **Cache:** `:file_store` (256 MB) in production
- **Process:** Puma (2 workers, 1–3 threads) with `puma_worker_killer`
- **Security:** Rack::Attack (throttling, spam blocklists, CJK blocking, notification logging), `force_ssl = true`
- **Test coverage:** ~3.8% — Minitest with fixtures
- **Dev environment:** Nix flake + direnv
- **VCS:** jj (colocated with git)

## Principles

- **Incremental:** Each phase is a separate jj bookmark, building on the last.
- **Small commits:** Each commit is self-contained, reversible, and reviewable. One logical change per commit. The app should be in a working state after every commit.
- **Test-first:** Baseline tests written before any changes to catch regressions.
- **Tight scope:** Only change what's required for the target upgrade. Don't modernize what still works.

---

## Completed Phases

### Phase 0: Safety Net Tests — DONE

Established regression tests covering critical paths before any changes.

### Phase 1: Bootstrap 3 → 5 — DONE

Migrated from `bootstrap-sass` (3.4) to `bootstrap` (5.3). Panels → cards, grid updates, form class migration (~136 occurrences across 21 views), data attributes, labels → badges, Kaminari Bootstrap 5 views.

### Phase 2: Rails 5.2 → 6.0 — DONE

Zeitwerk autoloader, `rails-ujs` (replaced `jquery_ujs`), class-level DB query constants converted to memoized class methods, `config.load_defaults '6.0'`.

### Phase 3: Rails 6.0 → 6.1 — DONE

Removed `represent_boolean_as_integer` config, converted raw SQL boolean scopes to `where(draft: false)`, `config.load_defaults '6.1'`.

### Phase 4: Ruby 2.7 → 3.2 — DONE

CSV kwargs fix (`**options`), `rss` gem added, Nix flake updated, systemd service updated to Ruby 3.2 path.

### Phase 5: CoffeeScript Removal — DONE (completed in Phase 2)

### Phase 6: rails_admin 2.x → 3.x, remove jQuery — DONE

### Feature Work (completed)

- **6a: CAPTCHA** — DONE. Replaced broken `acts_as_textcaptcha` with Cloudflare Turnstile. Direct API integration, no gem dependency. Keys in Rails encrypted credentials.
- **6b: Bluesky Feed** — DONE. `BlueskyFeed` model fetches from AT Protocol API with session auth. Tabbed UI on home page with Mastodon/Bluesky toggle, colour-switching icons.
- **6c: Threads Feed** — BLOCKED. Meta's Threads API requires OAuth app review for `threads_keyword_search` permission. Parked until API access is more accessible. UI is ready to add the tab.
- **6d: Social Media Handles** — DONE. Users have `mastodon_handle`, `bluesky_handle`, `threads_handle`, `twitter_handle` columns. Profile form updated, member page shows platform-specific icons.
- **6e: User Role Consolidation** — DONE. Single `role` column (`member`, `editor`, `admin`). `admin?` and `editor?` methods, `editor_or_admin?` helper.

### Infrastructure (completed)

- **HTTPS** — DONE. Let's Encrypt via Dreamhost panel for mesophotic.org, www, assets subdomain, and mesophotic.com. `force_ssl = true`, mailer protocol updated, hardcoded http:// URLs fixed.
- **Memory management** — DONE. Production cache switched from `:memory_store` to `:file_store` (256 MB cap). Added `puma_worker_killer` (768 MB RAM limit, 90% threshold, 6hr rolling restart).
- **Rack::Attack** — DONE. Search throttle (20/min), page throttle (300/min, excludes assets), spam pattern blocklist (URLs, spam TLDs, gambling/scam domains, CJK Unicode range blocks all Chinese/Japanese/Korean spam), IP blocklist (85.208.96.*), ActiveSupport::Notifications logging for all blocks and throttles. Note: Fail2Ban is incompatible with `:file_store` cache (increments on all requests regardless of block result) — needs Redis.
- **robots.txt** — DONE. Served via Rails route (Apache doesn't serve static files). Crawl-delay for all bots (2s), aggressive delay for bingbot (10s), block SEO scrapers (AhrefsBot, SemrushBot, MJ12bot), disallow search URLs, /admin/, /rails/active_storage/, *.csv, *.pdf.
- **CSV exports** — DONE. Require authentication. Download links hidden from anonymous visitors. Prevents bots from triggering expensive CSV generation queries (500-600ms each).

### Performance (completed)

- **N+1 queries** — DONE. Eager loading across pages, publications, and admin controllers. About page contributors batch-loaded via `@users_by_name` hash.

### UI Polish (completed)

- Bootstrap Icons 1.13.1 (replaced glyphicons and Font Awesome)
- Publication card restyling (outline badges, title link hover, font sizing)
- Open Access SVG icon restored
- Google Fonts URLs updated to HTTPS

---

## Remaining Phases

### Phase 7: Rails 6.1 → 7.0

**Bookmark:** `ryan/rails-7.0`
**Parent:** main
**Ruby:** 3.2

- `config.load_defaults '7.0'`.
- `rails app:update` — resolve config diffs.
- `button_to` default method changes from POST to PATCH in some contexts — audit forms.
- `Rails.application.credentials` changes — verify Figaro still works.
- `rails_admin` compatibility — verify current version works on Rails 7.0.

### Phase 8: Turbolinks → Turbo

**Bookmark:** `ryan/turbo`
**Parent:** `ryan/rails-7.0`
**Ruby:** 3.2, **Rails:** 7.0+

**IMPORTANT:** Turbo migration requires Rails 7.0 first. The `turbo-rails` 2.x gem's JavaScript does not compile through Sprockets on Rails 6.1 — `//= require turbo` silently fails and breaks all subsequent `//= require` directives. This was attempted and fully reverted.

- Remove `turbolinks` gem, add `turbo-rails`.
- `data-turbolinks-*` → `data-turbo-*`.
- Update `turbolinks:load` event listeners → `turbo:load` (in `charts.js`, `feed_tabs.js`, etc.).
- `turbolinks-cache-control` → `turbo-cache-control`.
- Update render_async config: `turbolinks` → `turbo`.

### Phase 9: Turbo Frames (replace render_async)

**Bookmark:** `ryan/turbo-frames`
**Parent:** `ryan/turbo`
**Ruby:** 3.2

Replace `render_async` with Turbo Frames across the app (~30 call sites). This enables proper caching behaviour (fixes the stats page caching issue) and removes the render_async gem dependency.

- Convert each `render_async` call to a `<turbo-frame>` with `src` attribute.
- Move async controller actions to return Turbo Frame responses.
- Remove `render_async` gem from Gemfile.
- Fix stats page caching (Turbo Frames handle this natively).

**Note:** Do NOT attempt to cache stats graphs until this phase is complete. Fragment caching + render_async don't mix (cached placeholder HTML loses the JavaScript that triggers async loading).

### Phase 10: Rails 7.0 → 7.1

**Bookmark:** `ryan/rails-7.1`
**Parent:** `ryan/turbo-frames`
**Ruby:** 3.2

- Mostly additive: async queries, `normalizes`, Trilogy adapter, BYO auth generator.
- `config.load_defaults '7.1'`.
- `rails app:update`.
- Verify all tests pass.
- Expected to be a smooth step.

### Phase 11: Rails 7.1 → 7.2

**Bookmark:** `ryan/rails-7.2`
**Parent:** `ryan/rails-7.1`
**Ruby:** 3.2

- `config.load_defaults '7.2'`.
- `rails app:update`.
- Progressive job enqueuing, default health check endpoint, dev containers.
- Verify all tests pass.

### Phase 12: Ruby 3.2 → 3.4

**Bookmark:** `ryan/ruby-3.4`
**Parent:** `ryan/rails-7.2`

- Update `.ruby-version` to `3.4`.
- Update Nix flake: change Ruby version.
- Ruby 3.3 changes: `it` as a block parameter name, Prism parser default.
- Ruby 3.4 changes: `frozen_string_literal` warning by default, `it` fully available.
- Run `bundle lock && bundix`.
- Run full test suite. Fix all failures.

### Phase 13: Rails 7.2 → 8.0

**Bookmark:** `ryan/rails-8.0`
**Parent:** `ryan/ruby-3.4`
**Ruby:** 3.4

- `config.load_defaults '8.0'`.
- `rails app:update`.
- Kamal 2 for deployment, Thruster as default proxy, Propshaft replaces Sprockets as default (but Sprockets still works).
- Solid Cable, Solid Cache, Solid Queue — new defaults but optional.
- Authentication generator available.
- `rails_admin` compatibility — verify works on Rails 8.0.
- **Note:** Sprockets → Propshaft migration is optional but recommended.

### Phase 14: Rails 8.0 → 8.1

**Bookmark:** `ryan/rails-8.1`
**Parent:** `ryan/rails-8.0`
**Ruby:** 3.4

- `config.load_defaults '8.1'`.
- `rails app:update`.
- Job continuations, structured events, local CI.
- Verify all tests pass.

---

## Remaining Feature Work

### 6c: Threads Feed (blocked)

Add a Threads `#mesophotic` feed alongside Mastodon and Bluesky feeds on the home page. Blocked by Meta's Threads API requiring OAuth app review for `threads_keyword_search` permission. Parked until API access improves. The tabbed UI is designed to accommodate additional feeds.

### 6f: Breadcrumb Navigation

Replace the `<<< Back` links throughout the app with proper breadcrumb navigation using Bootstrap 5's breadcrumb component.

- Create a shared breadcrumb partial that accepts a trail of label/path pairs.
- Replace `_page_title.html.erb` back link with breadcrumbs (e.g. Home > Publications > "Paper Title").
- Replace all admin `<<< Back` links with breadcrumbs (e.g. Home > Admin > Users > Edit).
- Replace summary page back links with breadcrumbs (e.g. Home > Locations > "American Samoa").
- Handle dynamic titles (publication names, location names, user emails).

### Canonical URL

Make `mesophotic.org` the canonical URL — remove the `www` redirect, and redirect `www.mesophotic.org` → `mesophotic.org` instead. Investigate where the current redirect is configured (Dreamhost panel, Apache config, or `.htaccess`).

---

## Future Work (Out of Scope)

These are noted for future planning but not part of this effort:

### Performance
- **word_association / species_association helper:** `application_helper.rb` loads ALL platforms, fields, focusgroups, locations, and species into memory every time it's called (per publication view). Cache per request or memoize.
- **CSV export memory:** `Publication#to_csv` builds large in-memory hashes for all associations before generating CSV. Consider streaming.
- **ResizeObserver cleanup:** `charts.js` creates ResizeObservers for wordclouds that may not be fully garbage collected on Turbolinks navigation. Add cleanup on `turbolinks:before-cache`.
- **MiniMagick → VIPS:** Switch Active Storage variant processor from MiniMagick (loads full image into memory) to VIPS (streams, much lower memory). Requires installing `libvips` on dev (Nix flake) and production (Dreamhost VPS). `ruby-vips` gem is already in the bundle.
- **Fragment caching — About page contributors:** 50+ `User.find_by` queries for contributors. Batch-load users in controller or cache the contributor cards.
- **Fragment caching — Home page publications:** Cache the newsfeed partial keyed on `Publication.maximum(:updated_at)`.
- **Fragment caching — News post cards:** Cache individual post summary cards keyed on `post.updated_at`.
- **Fragment caching — Publications sidebar charts:** Cache the focusgroup/field/platform/location bar charts on publications index.
- **Fragment caching — Members list:** Cache the member table keyed on `User.maximum(:updated_at)`.

### Technical Modernization
- **jQuery → vanilla JS / Stimulus:** Replace jQuery DOM manipulation and AJAX with Stimulus controllers and `fetch()`.
- **Sprockets → Propshaft or importmap-rails:** Modernize the asset pipeline. (Recommended during or after Rails 8.0.)
- **`owlcarousel-rails` → modern alternative:** The gem is unmaintained. Replace with a vanilla JS carousel or CSS-only solution.
- **`nested_form` / `remotipart` → Turbo Streams:** Replace legacy remote form gems with Hotwire patterns.
- **System tests:** Add Capybara-based browser tests for full user flow coverage.
- **HABTM → `has_many :through`:** Convert join tables for better auditability and flexibility.
- **Figaro → Rails credentials:** Migrate environment variable management.

## Risk Notes

- **Turbo migration (Phase 8):** `turbo-rails` 2.x JS does NOT compile through Sprockets on Rails 6.1. Must upgrade to Rails 7.0 first. Attempted and fully reverted — see Phase 8 notes.
- **Stats page caching:** Do NOT attempt to cache stats graphs until Turbo Frames migration (Phase 9). Fragment caching + render_async don't mix. Multiple approaches tried and all caused worse issues.
- **`rails_admin` 3.x (Rails 7.0):** Major rewrite. Config API changes, transitive dependencies removed. Cannot be deferred — `rails_admin` 2.x won't install on Rails 7.
- **Ruby 3.2 kwargs:** Already handled in Phase 4. Test suite is critical for catching remaining issues.
- **SQLite3 gem:** Version constraints may shift. The `~> 1.6.9` pin may need updating.
- **`owlcarousel-rails`:** Currently commented out in `application.js` and `application.scss`. Not actively breaking anything.
