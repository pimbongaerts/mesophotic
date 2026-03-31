# Bluesky Feed Design

**Date:** 2026-03-31
**Goal:** Add a Bluesky #mesophotic feed alongside the existing Mastodon feed on the home page, with tabbed logo selection to switch between them.

## Current State

- Mastodon feed on home page: `StatusFeed` class fetches RSS, parses into `Status` objects, fetches profiles server-side in parallel threads, cached for 1 hour via `Rails.cache.fetch`
- Loaded via render_async with a loading spinner placeholder
- Individual statuses fragment-cached by `content_url`
- `Status` PORO: `username`, `profile_url`, `content`, `content_url`, `published_at`, `avatar_url`, `display_name`

## Architecture

### Rename

- `StatusFeed` → `MastodonFeed` (Mastodon-specific: RSS parsing, Mastodon API profile fetching)
- `Status` stays as `Status` (shared data structure for both feeds)

### New: BlueskyFeed

New `BlueskyFeed` class that produces `Status` objects from the Bluesky public API.

**API:** `GET https://public.api.bsky.app/xrpc/app.bsky.feed.searchPosts?q=%23mesophotic`

The Bluesky API returns posts with author profile data inline (avatar, display name, handle) — no separate profile fetch needed. Parse the JSON response into `Status` objects matching the same interface as `MastodonFeed`.

### Controller

- Existing `mastodon_feed` action: update to use `MastodonFeed` (renamed from `StatusFeed`)
- New `bluesky_feed` action: same caching pattern (1 hour, busts on `User.maximum(:updated_at)`)
- New route: `get :bluesky_feed` in the pages collection

### View: Tabbed Feed Card

Both feeds loaded via render_async on the home page. JavaScript toggles visibility.

**Card header:**
- `#mesophotic` text + two logo icons (Mastodon, Bluesky)
- Logos act as tab selectors: click to switch which feed is visible
- Selected logo: full colour. Unselected: muted/grey opacity
- `#mesophotic` text colour matches active platform: Mastodon purple (`#595aff`), Bluesky blue (`#0085ff`)
- Default active tab: Mastodon

**Card body:**
- Two render_async containers (both load on page load)
- Only the active one is visible (`display: block` / `display: none`)
- Each has its own loading spinner placeholder

**Card footer:**
- Unchanged: "Use the #mesophotic hashtag to contribute"

**Tab switching JavaScript:**
- Vanilla JS click handler on the logo images
- Toggles visibility of the two feed containers
- Updates logo opacity (active: 1, inactive: 0.4)
- Updates `#mesophotic` text colour
- No Turbolinks or server interaction — pure client-side toggle

### Status Partial

`_status.html.erb` stays shared and unchanged. Both `MastodonFeed` and `BlueskyFeed` produce `Status` objects with the same fields.

### Feed Partials

- `_mastodon_feed.html.erb` — stays as-is (iterates statuses, per-status fragment cache)
- `_bluesky_feed.html.erb` — new, same structure as mastodon feed partial

### Logo Assets

- Mastodon: existing `mastodon_logo.png` (34x36px)
- Bluesky: new `bluesky_logo.svg` — official Bluesky butterfly in `#0085ff`

### Caching

- Mastodon feed: cached 1 hour, keyed on `["mastodon_feed", User.maximum(:updated_at)]` (existing)
- Bluesky feed: cached 1 hour, keyed on `["bluesky_feed", User.maximum(:updated_at)]`
- Individual statuses: fragment-cached by `["mastodon_status", content_url]` and `["bluesky_status", content_url]`

## Out of Scope

- Threads feed (Phase 6c — separate feature)
- User Bluesky handle matching (no `bluesky` column on User yet — that's Phase 6d)
- Bluesky user linking to member profiles (depends on 6d)
