# Bluesky Feed Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Bluesky #mesophotic feed alongside the existing Mastodon feed on the home page, with tabbed logo selection.

**Architecture:** Rename StatusFeed to MastodonFeed, create a new BlueskyFeed class that produces the same Status objects from the Bluesky public API, add a controller action with caching, and update the home page with tabbed feed switching via vanilla JS.

**Tech Stack:** Rails 6.1, Bluesky public API (no auth), vanilla JS for tab switching

**VCS:** jj. Work on bookmark `ryan/bluesky-feed`.

**Spec:** `docs/superpowers/specs/2026-03-31-bluesky-feed-design.md`

---

## File Structure

**Renamed files:**
- `app/models/status_feed.rb` → `app/models/mastodon_feed.rb`

**New files:**
- `app/models/bluesky_feed.rb` — fetch and parse Bluesky API response into Status objects
- `app/views/pages/_bluesky_feed.html.erb` — iterate statuses with per-status fragment cache
- `app/assets/images/bluesky_logo.svg` — official Bluesky butterfly in #0085ff
- `app/assets/javascripts/feed_tabs.js` — vanilla JS tab switching

**Modified files:**
- `app/controllers/pages_controller.rb` — update MastodonFeed reference, add bluesky_feed action
- `config/routes.rb` — add bluesky_feed route
- `app/views/pages/home.html.erb` — tabbed feed card with both logos
- `app/assets/javascripts/application.js` — require feed_tabs

---

### Task 1: Rename StatusFeed to MastodonFeed

- [x] Rename `app/models/status_feed.rb` to `app/models/mastodon_feed.rb`
- [x] Rename class `StatusFeed` to `MastodonFeed` inside the file
- [x] Update reference in `app/controllers/pages_controller.rb`
- [x] Run tests
- [x] Commit: "Rename StatusFeed to MastodonFeed"

### Task 2: Create BlueskyFeed class

- [x] Create `app/models/bluesky_feed.rb`
- [x] Fetch from Bluesky public API with `#mesophotic` hashtag search
- [x] Parse JSON response into Status objects (avatar_url and display_name from inline author data)
- [x] Handle rich text facets (links, mentions, hashtags) in post content
- [x] Graceful failure on API errors (empty feed)
- [x] Run tests
- [x] Commit: "Add BlueskyFeed class: fetch #mesophotic posts from Bluesky public API"

### Task 3: Add controller action, route, and feed partial

- [x] Add `bluesky_feed` action to PagesController (1 hour cache, keyed on User.maximum(:updated_at))
- [x] Add `get :bluesky_feed` route in pages collection
- [x] Create `app/views/pages/_bluesky_feed.html.erb` with per-status fragment caching
- [x] Run tests
- [x] Commit: "Add bluesky_feed controller action, route, and feed partial"

### Task 4: Update home page with tabbed feed card

- [x] Add Bluesky butterfly logo SVG
- [x] Update home page: two logos in card header as tab selectors, both feeds loaded via render_async
- [x] Create feed_tabs.js for tab switching (show/hide feeds, toggle logo opacity, change #mesophotic text colour)
- [x] Mastodon purple (#595aff) when active, Bluesky blue (#0085ff) when active
- [x] Default active tab: Mastodon
- [x] Run tests
- [x] Commit: "Add tabbed Mastodon/Bluesky feed on home page with logo switching"

---

## Manual Test Plan

- [ ] Home page loads with Mastodon feed visible by default
- [ ] Bluesky logo in header, muted (0.4 opacity)
- [ ] Click Bluesky logo: feed switches to Bluesky posts, logo full colour, Mastodon muted, #mesophotic turns blue
- [ ] Click Mastodon logo: switches back, colours revert to purple
- [ ] Bluesky posts show: avatar, display name, handle, relative time, content with links
- [ ] Both feeds load via render_async (loading spinner shown briefly)
- [ ] With `rails dev:cache`: second page load serves both feeds from cache instantly
- [ ] Browser console: no JS errors
