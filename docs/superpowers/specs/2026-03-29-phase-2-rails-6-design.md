# Phase 2: Rails 5.2 → 6.0 Design

**Date:** 2026-03-29
**Goal:** Upgrade from Rails 5.2.8 to Rails 6.0, switch to Zeitwerk autoloader, migrate from jquery_ujs to rails-ujs, port all custom JS off jQuery, and clean up dead code.

## Current State

- Rails 5.2.8.1, Ruby 2.7, Bootstrap 5.3 (Phase 1 complete)
- 162+ tests passing (Phase 0 safety net)
- Classic autoloader with `config.load_defaults 5.2`
- jQuery used in: mastodon_avatars.js, 8 Highcharts graph partials, wordcloud partial, Devise drag-drop form, render_async config, custom `sizeChanged` plugin
- `jquery_ujs` for UJS behaviour
- `rails_admin` 2.3.1 has a hard dependency on `jquery-rails` — jQuery gem stays until Phase 4d

## Principles

- **Fewer dependencies:** Port all custom JS off jQuery now. Keep `jquery-rails` only because `rails_admin` 2.x requires it. Full removal happens in Phase 4d when `rails_admin` upgrades to 3.x.
- **Clean up dead code** along the way (owl carousel, analytics.coffee, dead configs).
- **One logical change per commit**, app working after each.

## Scope

### In Scope

1. Bump Rails to 6.0
2. Switch to Zeitwerk autoloader
3. Fix Publication class-level DB queries (Zeitwerk hazard)
4. Split `StatusFeed`/`Status` into separate files (Zeitwerk one-class-per-file rule)
5. Migrate `jquery_ujs` → `rails-ujs`
6. Port custom JS off jQuery:
   - `mastodon_avatars.js` — `$.ajax` → `fetch`, jQuery DOM → vanilla
   - 8 Highcharts graph partials — `$(function(){})` → `DOMContentLoaded`, `$('#id').highcharts()` → `Highcharts.chart('id', ...)`
   - 2 map partials — same pattern as graphs
   - `_wordcloud.html.erb` — same ready callback + replace `sizeChanged` plugin with `ResizeObserver`
   - Devise `_form.html.erb` drag-drop — jQuery selectors/events → vanilla DOM
   - Remove custom `sizeChanged` jQuery plugin from `application.js`
7. Switch `render_async` config from `jquery: true` to `jquery: false`
8. Remove dead code: `owlcarousel-rails` gem, `_slider.html.erb`, `analytics.js.coffee`
9. Clean up deprecated configs
10. Update `config.load_defaults` to `6.0`

### Out of Scope

- Removing `jquery-rails` gem (blocked by `rails_admin` 2.x — deferred to Phase 4d)
- Rails credentials migration (Figaro still works)
- Boolean scope rewrites in Post model (works fine on 6.0, address in Phase 3 with `represent_boolean_as_integer` removal)
- Action Text / Action Mailbox (not needed)
- Ruby version change (stays 2.7)

## Architecture

### Zeitwerk Migration

**`config/application.rb` changes:**
- `config.load_defaults 5.2` → `config.load_defaults 6.0`
- Remove `config.active_record.sqlite3.represent_boolean_as_integer = true` (deprecated in 6.0, removed in 6.1 — remove now to avoid carrying it forward)

**`config/initializers/application.rb` changes:**
- Remove `autoload_paths` manipulation (Zeitwerk handles `app/` automatically; `lib/` only contains `MarkdownWriter` and rake tasks)
- Remove dead `raise_in_transactional_callbacks` line
- Move `MarkdownWriter` from `lib/` to `app/services/` or add `lib/` to `config.eager_load_paths` in `application.rb`

**Publication model constants (lines 47-51):**

Five constants execute DB queries at class load time:
```ruby
PUBLICATION_CHARACTERISTICS = Publication.columns.select { |c| c.sql_type =~ /^boolean/ }.map(&:name).sort.freeze
PUBLICATION_LOCATIONS = Location.select(:description).order(:description).map(&:description).uniq.freeze
PUBLICATION_FOCUSGROUPS = Focusgroup.select(:description).order(:description).map(&:description).uniq.freeze
PUBLICATION_PLATFORMS = Platform.select(:description).order(:description).map(&:description).uniq.freeze
PUBLICATION_FIELDS = Field.select(:description).order(:description).map(&:description).uniq.freeze
```

Under Zeitwerk, if `Publication` is loaded before the DB is ready (e.g. during `db:migrate`, `assets:precompile`), these raise errors. Convert to memoized class methods:

```ruby
def self.publication_characteristics
  @publication_characteristics ||= columns.select { |c| c.sql_type =~ /^boolean/ }.map(&:name).sort.freeze
end
```

Update the 5 references in `_search_field.html.erb` and 1 in `publication.rb` to use the method form.

**StatusFeed / Status split:**

`app/models/status_feed.rb` defines both `StatusFeed` and `Status`. Neither inherits from `ApplicationRecord` — they're POROs. Split `Status` into its own file. Since these aren't AR models, move both to `app/services/` (or `app/models/` is fine too — Zeitwerk doesn't care about the directory, just one-class-per-file).

### UJS Migration

Replace `//= require jquery_ujs` with `//= require rails-ujs` in `application.js`. Rails 6.0 ships `rails-ujs` built-in (no extra gem needed). It's a drop-in replacement — `data-method`, `data-confirm`, and `data-remote` attributes work identically.

### jQuery Removal from Custom Code

**`mastodon_avatars.js`** (largest change):
- `$(document).on('turbolinks:load', ...)` → `document.addEventListener('turbolinks:load', ...)`
- `$('.mastodon-avatar').each(...)` → `document.querySelectorAll('.mastodon-avatar').forEach(...)`
- `$.ajax({url, data, success})` → `fetch()` with query params and `.then()`
- `el.data('profile-url')` → `el.dataset.profileUrl`
- `el.closest(...)`, `.find(...)`, `.text(...)`, `.html(...)`, `.show()` → vanilla equivalents

**8 Highcharts graph partials** (`_bar_graph`, `_area_graph`, `_pie_graph`, etc.) + 2 map partials:
- `$(function() { $('#graph_x').highcharts({...}) })` → `document.addEventListener('DOMContentLoaded', function() { Highcharts.chart('graph_x', {...}) })`
- Highcharts is framework-agnostic. The `$('#id').highcharts()` syntax is a jQuery adapter; `Highcharts.chart(id, options)` is the native API and doesn't need jQuery at all.

**`_wordcloud.html.erb`:**
- `$('#wordcloud_x')[0]` → `document.getElementById('wordcloud_x')`
- `$(function() { ... })` → `document.addEventListener('DOMContentLoaded', ...)`
- `$('#wordcloud_x').sizeChanged(f)` → `new ResizeObserver(f).observe(el)` (modern, no polling)

**Devise `_form.html.erb` drag-drop (lines 75-117):**
- `$('#id')` → `document.getElementById('id')`
- `.on('click', fn)` → `.addEventListener('click', fn)`
- `.css('prop', 'val')` → `.style.prop = val`
- `.attr('src', val)` → `.src = val`
- `.show()` / `.hide()` → `.style.display = ''` / `.style.display = 'none'`
- `e.originalEvent.dataTransfer` → `e.dataTransfer` (no jQuery wrapper)

**`application.js` custom `sizeChanged` plugin (lines 23-44):**
- Delete entirely. Only consumer is `_wordcloud.html.erb`, which will use `ResizeObserver` instead.

**`render_async` config:**
- Change `config.jquery = true` to `config.jquery = false` in `config/initializers/render_async.rb`. render_async will use vanilla JS XHR instead of jQuery AJAX.

### Dead Code Removal

- **`owlcarousel-rails`:** Gem in Gemfile, but `_slider.html.erb` is not rendered anywhere and `owl.carousel` is commented out in `application.js`. Remove gem from Gemfile and delete `_slider.html.erb`.
- **`analytics.js.coffee`:** Commented out in `application.js` (`// = require analytics`). Uses legacy `_gaq` / `pageTracker` API (not modern GA4). Delete the file.
- **`coffee-rails`:** After deleting `analytics.js.coffee`, check if any `.coffee` files remain. If none, remove `coffee-rails` from Gemfile.

### Gem Updates

- `rails` `~> 5.2.8` → `~> 6.0`
- Remove `owlcarousel-rails`
- Remove `coffee-rails` (if no .coffee files remain)
- Keep `jquery-rails` (rails_admin dependency)
- Verify compatibility: `rails_admin`, `paper_trail`, `acts_as_textcaptcha`, `switch_user`, `render_async`, `devise`, `friendly_id`, `kaminari`
- Run `bundle install`, `bundle lock`, `bundix`

### Config Changes

**`config/application.rb`:**
- `config.load_defaults 5.2` → `config.load_defaults 6.0`
- Remove `config.active_record.sqlite3.represent_boolean_as_integer = true`

**`config/initializers/application.rb`:**
- Remove `autoload_paths` lines
- Remove `raise_in_transactional_callbacks` line
- If `MarkdownWriter` needs to stay in `lib/`, add `config.eager_load_paths << Rails.root.join('lib')` to `application.rb`

**`config/environments/production.rb`:**
- `config.require_master_key = true` is now default in 6.0 — can optionally remove (not breaking if kept)

**`rails app:update`:**
- Run and resolve config diffs. New 6.0 config files may be generated (e.g. `config/initializers/new_framework_defaults_6_0.rb`).

### Nix

- Update `flake.nix` if Rails 6.0 needs a newer Bundler or native dependency.
- Ruby stays at 2.7.
- Run `bundle lock && bundix` after all Gemfile changes.

## Risk Notes

- **Zeitwerk naming:** `bin/rails zeitwerk:check` is the diagnostic. Run it after switching autoloaders to catch any naming violations beyond the ones identified here.
- **render_async with `jquery: false`:** Verify all 33 render_async call sites still load correctly. The switch should be transparent but warrants testing.
- **Highcharts API:** The `$('#id').highcharts()` → `Highcharts.chart('id', opts)` migration changes the call signature slightly. Verify all 10 graph/map partials render correctly.
- **ResizeObserver:** Supported in all modern browsers. No polyfill needed for the target audience.
- **rails_admin 2.x on Rails 6.0:** Should work (its constraint is `rails >= 5.0, < 7`), but verify the admin interface still functions after the upgrade.

## Test Plan

### Automated (run after every commit)

```bash
rails test
```

Expected: All 162+ tests pass with 0 failures throughout.

### Manual Testing Checklist (for PR review)

**Core navigation:**
- [ ] Home page loads, navbar works, all links functional
- [ ] Page transitions via Turbolinks still work (no full reloads)
- [ ] Flash messages appear and can be dismissed

**UJS behaviour (rails-ujs):**
- [ ] Any `data-method="delete"` links work (e.g. sign out)
- [ ] Any `data-confirm` dialogs appear
- [ ] Any `data-remote="true"` forms/links submit via AJAX

**Mastodon feed (home page):**
- [ ] Mastodon statuses load on home page
- [ ] Profile avatars load asynchronously (check network tab for `/api/v1/accounts/lookup` requests)
- [ ] Display names populate next to avatars
- [ ] Handles show correctly
- [ ] Bluesky tab still works if implemented

**Graphs and charts (stats pages):**
- [ ] `/stats` — all chart types render: bar, area, pie, column, depth
- [ ] Charts are interactive (hover tooltips, click events)
- [ ] World map renders with data points
- [ ] Summary pages — author/location/species charts render

**Wordcloud:**
- [ ] Wordcloud renders on relevant pages
- [ ] Words are clickable (navigate to associated page)
- [ ] Wordcloud resizes correctly when browser window resizes (ResizeObserver replacing sizeChanged)

**Publications:**
- [ ] `/publications` — search works, filters work (characteristics, locations, focusgroups, platforms, fields)
- [ ] Dual range slider functions
- [ ] Pagination works (Kaminari)
- [ ] CSV export works
- [ ] Publication show page loads correctly
- [ ] render_async partials load (related publications, maps, etc.)

**Devise / Auth:**
- [ ] Sign in page renders and works
- [ ] Sign up page renders and works
- [ ] Profile edit page — drag-drop photo upload works (drag image onto zone, preview shows)
- [ ] Profile edit page — click-to-browse photo upload works
- [ ] Sign out works

**render_async (33 call sites):**
- [ ] Spot-check 5-6 pages that use render_async: home, publications/show, stats, species, locations, summary
- [ ] Deferred partials load without errors (no jQuery-related console errors)

**Admin (rails_admin):**
- [ ] `/admin/db` loads (rails_admin dashboard)
- [ ] Can browse models, edit a record
- [ ] jQuery still works within admin interface (rails_admin bundles its own)

**Browser console:**
- [ ] No JavaScript errors on any tested page
- [ ] No failed network requests (aside from expected external API timeouts)

**Species page:**
- [ ] Accordion expand/collapse works
- [ ] Species data loads correctly

**Locations page:**
- [ ] Map renders with markers
- [ ] Dropdown location selection works
- [ ] Featured location card displays

**Members page:**
- [ ] Member list loads
- [ ] Member profile pages load
- [ ] render_async sections load on profile pages
