# Mesophotic.org Modernization Design

**Date:** 2026-03-25 (last updated 2026-04-07)
**Goal:** Bring the application from Rails 5.2 / Ruby 2.7 / Bootstrap 3 to Rails 8.1 / Ruby 3.4, with a baseline test suite as a safety net.

## Current State

- **Rails** 8.1, **Ruby** 3.4, **Bootstrap** 5.3 (via `bootstrap` gem)
- **Frontend:** Propshaft, importmap-rails, Turbo Drive + Turbo Frames, dartsass-rails, Bootstrap 5.3 (gem), Bootstrap Icons, vanilla JS, SCSS
- **Database:** SQLite3 (all environments)
- **Auth:** Devise with Cloudflare Turnstile CAPTCHA on registration
- **Admin:** rails_admin (mounted at `/admin/db`)
- **Cache:** `:file_store` (256 MB) in production
- **Process:** Puma (2 workers, 1–3 threads) with `puma_worker_killer`
- **Security:** Rack::Attack (throttling, spam blocklists, CJK/Korean blocking, notification logging), `force_ssl = true`
- **Test coverage:** ~3.8% — Minitest with fixtures
- **Dev environment:** Nix flake + direnv
- **VCS:** jj (colocated with git)

## Principles

- **Incremental:** Each phase is a separate jj bookmark, building on the last.
- **Small commits:** Each commit is self-contained, reversible, and reviewable. One logical change per commit. The app should be in a working state after every commit.
- **Test-first:** Baseline tests written before any changes to catch regressions.
- **Tight scope:** Only change what's required for the target upgrade. Don't modernize what still works.

---

## Core Upgrades

| # | Description | Status |
|---|-------------|--------|
| 1 | Safety net tests | Done |
| 2 | Bootstrap 3 → 5 | Done |
| 3 | Rails 5.2 → 6.0 (Zeitwerk, rails-ujs) | Done |
| 4 | Rails 6.0 → 6.1 | Done |
| 5 | Ruby 2.7 → 3.2 | Done |
| 6 | CoffeeScript removal | Done |
| 7 | rails_admin 3.x, remove jQuery | Done |
| 8 | Rails 6.1 → 7.0 | Done |
| 9 | Rails 7.0 → 7.1 | Done |
| 10 | Rails 7.1 → 7.2 | Done |
| 11 | Ruby 3.2 → 3.4 | Done |
| 12 | Rails 7.2 → 8.0 | Done |
| 13 | Rails 8.0 → 8.1 | Done |
| 14 | Sprockets → Propshaft + importmap + Turbolinks → Turbo | Done |
| 15 | Turbo Frames (replace render_async) | Done |
| **16** | **Local CI runner (bin/ci, RuboCop, Brakeman)** | **Next** |

## Features

| # | Description | Status |
|---|-------------|--------|
| 1 | CAPTCHA (Cloudflare Turnstile) | Done |
| 2 | Bluesky feed | Done |
| 3 | Threads feed | Blocked (Meta API) |
| 4 | Social media handles | Done |
| 5 | User role consolidation | Done |
| 6 | Breadcrumb navigation | Done |

## Infrastructure

| # | Description | Status |
|---|-------------|--------|
| 1 | HTTPS / Let's Encrypt | Done |
| 2 | Memory management (file_store, puma_worker_killer) | Done |
| 3 | Rack::Attack (throttles, CJK block, spam patterns, logging) | Done |
| 4 | robots.txt (crawl-delay, disallow storage/csv/pdf) | Done |
| 5 | CSV exports require auth, links hidden | Done |
| 6 | Canonical URL (www → mesophotic.org) | Todo |
| 7 | Automated deployment (Capistrano, manual trigger, rollback) | Todo |

## Security

| # | Description | Status |
|---|-------------|--------|
| 1 | Brakeman scan + fix findings | Done |
| 2 | OWASP top 10 audit (access control, auth, XSS, SQL injection) | Done |
| 3 | Content Security Policy (enforced, nonces, vendored Bootstrap Icons) | Done |
| 4 | Dependency vulnerability scan (bundler-audit) | Done |

## Performance

| # | Description | Status |
|---|-------------|--------|
| 1 | N+1 query fixes, eager loading | Done |
| 2 | Fragment caching (about, home, posts, sidebar, members) | Done |
| 3 | Species image caching (24hr) + spinner | Done |
| 4 | word_association / species_association caching | Done |
| 5 | CSV export streaming | Done |
| 6 | ResizeObserver cleanup in charts.js | Done |
| 7 | Species image bug (open() → URI.open, HTTPS) | Done |
| 8 | ~~MiniMagick → VIPS~~ | Dropped (libvips not available on Dreamhost) |
| 9 | SQL query profiling + slow query analysis | Todo |
| 10 | Missing database indexes audit | Todo |
| 11 | Remaining N+1 query audit (bullet gem or log analysis) | Todo |

## UI

| # | Description | Status |
|---|-------------|--------|
| 1 | Bootstrap Icons 1.13.1 | Done |
| 2 | Publication card restyling (index) | Done |
| 3 | Publication show page polish (badges, supertitle, icons, caching) | Done |
| 4 | Open Access SVG icon | Done |
| 5 | Google Fonts HTTPS | Done |

---

## Completed Details

### Phases 0–6: Core Upgrades

- **Phase 0:** Regression tests covering critical paths before any changes.
- **Phase 1:** `bootstrap-sass` (3.4) → `bootstrap` (5.3). Panels → cards, grid, forms (~136 occurrences across 21 views), data attributes, labels → badges, Kaminari views.
- **Phase 2:** Zeitwerk autoloader, `rails-ujs` (replaced `jquery_ujs`), class-level DB query constants → memoized class methods, `config.load_defaults '6.0'`.
- **Phase 3:** Removed `represent_boolean_as_integer`, boolean scopes → `where(draft: false)`, `config.load_defaults '6.1'`.
- **Phase 4:** CSV kwargs fix (`**options`), `rss` gem added, Nix flake updated, systemd service → Ruby 3.2 path.
- **Phase 5:** CoffeeScript removed (completed in Phase 2).
- **Phase 6:** rails_admin 3.x, jQuery removed.
- **Phases 7–13:** Incremental Rails upgrades (6.1→7.0→7.1→7.2→8.0→8.1), Ruby 3.2→3.4. Each phase: `config.load_defaults`, `rails app:update`, fix deprecations, verify tests.
- **Phase 14:** Sprockets → Propshaft + importmap-rails + Turbolinks → Turbo Drive. Bootstrap 5.3 via gem + popper_js gem. dartsass-rails for SCSS. RailsAdmin uses importmap asset_source with vendored CSS from rails_admin-nobuild. Highcharts/WordCloud2/feed_tabs as Propshaft script tags.
- **Phase 15:** render_async → Turbo Frames. Shared `render_in_turbo_frame` helper in ApplicationController. 35 calls across 8 controllers converted. render_async gem removed entirely.

### Features

- **6a: CAPTCHA** — Replaced broken `acts_as_textcaptcha` with Cloudflare Turnstile. Direct API integration, no gem. Keys in Rails encrypted credentials.
- **6b: Bluesky Feed** — `BlueskyFeed` model fetches from AT Protocol API with session auth. Tabbed UI on home page with Mastodon/Bluesky toggle, colour-switching icons.
- **6c: Threads Feed** — BLOCKED. Meta's Threads API requires OAuth app review for `threads_keyword_search`. Parked until API access improves. UI is ready to add the tab.
- **6d: Social Media Handles** — `mastodon_handle`, `bluesky_handle`, `threads_handle`, `twitter_handle` columns. Profile form updated, member page shows platform-specific icons.
- **6e: User Role Consolidation** — Single `role` column (`member`, `editor`, `admin`). `admin?`, `editor?`, `editor_or_admin?` methods.

### Infrastructure

- **HTTPS** — Let's Encrypt via Dreamhost panel for mesophotic.org, www, assets, and mesophotic.com. `force_ssl = true`, mailer protocol updated, hardcoded http:// URLs fixed.
- **Memory management** — Production cache: `:memory_store` → `:file_store` (256 MB cap). Added `puma_worker_killer` (768 MB RAM limit, 90% threshold, 6hr rolling restart).
- **Rack::Attack** — Search throttle (20/min), page throttle (300/min, excludes assets), spam pattern blocklist (URLs, spam TLDs, gambling/scam domains, CJK Unicode range blocks all Chinese/Japanese/Korean spam), IP blocklist (85.208.96.*), ActiveSupport::Notifications logging for all blocks and throttles. Note: Fail2Ban is incompatible with `:file_store` cache (increments on all requests regardless of block result) — needs Redis.
- **robots.txt** — Served via Rails route (Apache doesn't serve static files). Crawl-delay for all bots (2s), 10s for bingbot, block SEO scrapers (AhrefsBot, SemrushBot, MJ12bot), disallow search URLs, /admin/, /rails/active_storage/, *.csv, *.pdf.
- **CSV exports** — Require authentication. Download links hidden from anonymous visitors. Prevents bots triggering expensive CSV queries (500-600ms each).

### Performance

- **N+1 queries** — Eager loading across pages, publications, and admin controllers. About page contributors batch-loaded via `@users_by_name` hash.
- **Fragment caching** — Cache blocks on about page contributors, home page publications, news post cards, publications sidebar charts, and members list.

### UI Polish

- Bootstrap Icons 1.13.1 (replaced glyphicons and Font Awesome)
- Publication card restyling (outline badges, title link hover, font sizing)
- Open Access SVG icon restored
- Google Fonts URLs updated to HTTPS

---

## Remaining Security Work

### Security audit

Run Brakeman and bundler-audit to get a baseline. Manually review OWASP top 10 areas:

- **SQL injection** — Audit raw SQL in model scopes and controller queries (stats, summary, publications). Check for string interpolation in `.where()` clauses.
- **XSS** — Audit `.html_safe` usage across views and controllers (including `render_in_turbo_frame`). Check for unescaped user input.
- **CSRF** — Verify `protect_from_forgery` coverage, especially on Turbo Frame endpoints.
- **Mass assignment** — Audit `permit` params in controllers for over-permissive whitelists.
- **Content Security Policy** — Review `config/initializers/content_security_policy.rb`, tighten if possible.
- **Dependency vulnerabilities** — `bundle audit` for known CVEs in gems.

### Remaining Performance Work

### SQL profiling + slow queries

Profile production queries via New Relic or `rack-mini-profiler` in development. Identify:

- Slow queries (>100ms) — especially on stats pages, publication search, and CSV exports.
- Missing indexes — audit foreign keys and columns used in `WHERE`, `JOIN`, and `ORDER BY` clauses.
- Remaining N+1 queries — use `bullet` gem in development to catch lazy-loaded associations the earlier eager loading work missed.
- `word_association` / `species_association` helpers still load all records per call — consider further caching or restructuring.
- `Publication#to_csv` builds large in-memory hashes — consider streaming or batching.

## Remaining Feature Work

### Threads Feed (blocked)

Add a Threads `#mesophotic` feed alongside Mastodon and Bluesky feeds on the home page. Blocked by Meta's Threads API requiring OAuth app review for `threads_keyword_search` permission. Parked until API access improves. The tabbed UI is designed to accommodate additional feeds.

### Canonical URL

Make `mesophotic.org` the canonical URL — remove the `www` redirect, and redirect `www.mesophotic.org` → `mesophotic.org` instead. Investigate where the current redirect is configured (Dreamhost panel, Apache config, or `.htaccess`).

### Automated Deployment

Replace manual SSH + `scripts/update_and_restart.sh` workflow with automated deployment. Current script does: `git pull`, `bundle install`, `db:migrate`, clear cache, `assets:precompile`, update crontab, `touch tmp/restart.txt`.

**Plan:** Capistrano. Manually triggered (`cap production deploy`), not auto-deploy on merge. Provides versioned releases, instant rollback (`cap production deploy:rollback`), and replaces the current `scripts/update_and_restart.sh` steps with a structured deploy process.

- Add `capistrano`, `capistrano-rails`, `capistrano-bundler`, `capistrano-rbenv` (or similar for Nix Ruby) to Gemfile
- Configure `config/deploy.rb` and `config/deploy/production.rb` for Dreamhost VPS
- Map current script steps to Capistrano tasks: git pull → checkout release, bundle install, db:migrate, assets:precompile, cache clear, crontab update, restart
- Symlink shared config (application.yml, master.key, storage, etc.)
- Test rollback works cleanly

---

## Future Work (Out of Scope)

These are noted for future planning but not part of this effort:

### Performance
- **word_association / species_association helper:** `application_helper.rb` loads ALL platforms, fields, focusgroups, locations, and species into memory every time it's called (per publication view). Cache per request or memoize.
- **CSV export memory:** `Publication#to_csv` builds large in-memory hashes for all associations before generating CSV. Consider streaming.
- ~~**MiniMagick → VIPS:**~~ Dropped. `libvips` is not available on Dreamhost shared hosting and can't be compiled without `meson`. Not worth the effort.

### Technical Modernization
- **jQuery → vanilla JS / Stimulus:** Replace jQuery DOM manipulation and AJAX with Stimulus controllers and `fetch()`.
- **`owlcarousel-rails` → modern alternative:** The gem is unmaintained. Replace with a vanilla JS carousel or CSS-only solution.
- **`nested_form` / `remotipart` → Turbo Streams:** Replace legacy remote form gems with Hotwire patterns.
- **System tests:** Add Capybara-based browser tests for full user flow coverage.
- **HABTM → `has_many :through`:** Convert join tables for better auditability and flexibility.
- **Figaro → Rails credentials:** Migrate environment variable management.

## Lessons Learned

- **Turbo requires Rails 7.0+:** `turbo-rails` 2.x JS does not compile through Sprockets on Rails 6.1. Attempted and reverted.
- **Sprockets + Propshaft can't coexist:** Both register as the asset pipeline. RailsAdmin needed vendored CSS + importmap to work without Sprockets.
- **render_async + Turbo Drive incompatible:** Inline `<script>` tags injected via `content_for` don't re-evaluate under Turbo Drive. Replaced with Turbo Frames.
- **Nix bundlerEnv freezes bundler:** Use `nix shell nixpkgs#ruby_3_4 --command bundle lock` to bypass. Script at `scripts/generate_nix_gemfile_lock_and_gemset.sh`.
- **`owlcarousel-rails`:** Currently commented out in `application.js` and `application.scss`. Not actively breaking anything.
