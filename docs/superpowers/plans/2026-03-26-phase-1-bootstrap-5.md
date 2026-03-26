# Phase 1: Bootstrap 3 → 5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Migrate from Bootstrap 3.4.1 (`bootstrap-sass` gem) to Bootstrap 5.3 (`bootstrap` gem) while keeping the app visually functional and all tests passing.

**Architecture:** Swap the gem, restructure SCSS (variables before imports), then systematically find-and-replace BS3 classes with BS5 equivalents across all views. One component type per commit. Tests run after each commit to catch regressions.

**Tech Stack:** Bootstrap 5.3 via `bootstrap` gem, `sassc-rails`, Sprockets, jQuery (kept for now)

**VCS:** jj. Create bookmark `ryan/bootstrap-5` stacked on `ryan/fix-deprecation-warnings`.

**Spec:** `docs/superpowers/specs/2026-03-25-rails-modernization-design.md` (Phase 1 section)

---

## File Structure

**Modified gem/asset files:**
- `Gemfile` — swap `bootstrap-sass` → `bootstrap`, remove `sass` gem
- `app/assets/stylesheets/railsbricks_custom.scss` — restructure imports, rename variables, fix `@extend`
- `app/assets/stylesheets/application.scss` — update import if needed
- `app/assets/javascripts/application.js` — update bootstrap require

**Modified layout files:**
- `app/views/layouts/_navigation.html.erb` — navbar classes
- `app/views/layouts/_navigation_links.html.erb` — navbar-right → ms-auto
- `app/views/layouts/_user_links.html.erb` — dropdown data attributes, responsive
- `app/views/layouts/_link_categories.html.erb` — dropdown data attributes, responsive
- `app/views/layouts/_messages.html.erb` — alert dismiss data attribute
- `app/views/layouts/application.html.erb` — grid offset

**Modified view files (panels → cards):**
- `app/views/devise/registrations/_form.html.erb`
- `app/views/publications/index.html.erb`
- `app/views/publications/_search_field.html.erb`
- `app/views/species/_specieslist.html.erb`
- `app/views/stats/index.html.erb` (and any stats partials using panels)
- All other views with `panel` classes

**Modified view files (form-group → mb-3):**
- 21 files — all listed in the audit

**Modified view files (labels → badges):**
- `app/views/publications/_publication_validation.html.erb`
- `app/views/admin/publications/_publication_validation.html.erb`

**Modified view files (bare badge → badge bg-secondary):**
- 12 files — all listed in the audit

**Modified view files (data attributes):**
- `app/views/species/_specieslist.html.erb`
- `app/views/summary/_author.html.erb`
- `app/views/shared/_list_categories.html.erb`
- `app/views/publications/_search_field.html.erb`

**Modified view files (grid):**
- All views using `col-xs-*` → `col-*`

---

### Task 1: Create bookmark and swap Bootstrap gem

**Files:**
- Modify: `Gemfile`

- [ ] **Step 1: Create jj bookmark**

```bash
jj bookmark create ryan/bootstrap-5
```

- [ ] **Step 2: Update Gemfile**

Replace:
```ruby
gem 'bootstrap-sass', '~> 3.4.1'
```
With:
```ruby
gem 'bootstrap', '~> 5.3'
```

Also remove the standalone `sass` gem if present (deprecated; `sassc-rails` handles compilation).

- [ ] **Step 3: Bundle install**

```bash
bundle install
```

If `sassc-rails` is not already in the Gemfile, add it. The `bootstrap` gem requires it.

- [ ] **Step 4: Update lock and Nix gemset**

```bash
bundle lock
bundix
```

- [ ] **Step 5: Commit**

```bash
jj describe -m "Swap bootstrap-sass gem for bootstrap 5.3" && jj new
```

Note: The app will NOT compile at this point — SCSS imports are broken. That's expected; we fix it in Task 2.

---

### Task 2: Restructure SCSS — variables before imports

**Files:**
- Modify: `app/assets/stylesheets/railsbricks_custom.scss`

This is the most critical task. Bootstrap 5 requires variable overrides BEFORE the `@import "bootstrap"` line (BS5 uses `!default` flags). The current file has `@import "bootstrap"` at line 2, before all variable definitions.

- [ ] **Step 1: Read the current file**

Read `app/assets/stylesheets/railsbricks_custom.scss` completely to understand its structure.

- [ ] **Step 2: Restructure the file**

The file must be reorganized into this order:
1. Google Fonts import (keep at top)
2. Bootstrap Icons CDN import (keep)
3. **All variable overrides** (moved from below the import to above it)
4. **`@import "bootstrap"`** (moved from line 2 to after all variables)
5. All custom CSS rules (keep after import)

- [ ] **Step 3: Rename BS3 variables to BS5 equivalents**

Key renames in the variable section:

| BS3 Variable | BS5 Variable |
|---|---|
| `$brand-primary` | `$primary` |
| `$brand-success` | `$success` |
| `$brand-info` | `$info` |
| `$brand-warning` | `$warning` |
| `$brand-danger` | `$danger` |
| `$font-size-base: 14px` | `$font-size-base: 0.875rem` |
| `$font-family-sans-serif` | `$font-family-sans-serif` (same name, keep) |
| `$body-bg` | `$body-bg` (same name, keep) |
| `$text-color` | `$body-color` |
| `$link-color` | `$link-color` (same name, keep) |
| `$link-hover-color` | `$link-hover-color` (same name, keep) |
| `$btn-default-*` | Remove (no "default" variant in BS5; becomes `$btn-secondary-*` or remove entirely) |
| `$navbar-default-*` | Remove (BS5 uses `.navbar-light` / `.navbar-dark` with utility classes) |
| `$navbar-height` | Remove (BS5 doesn't have this variable; use custom CSS) |
| `$panel-*` | Remove (panels don't exist in BS5; cards use different variables) |
| `$label-*` | Remove (labels don't exist in BS5; badges use different variables) |
| `$input-height-base` | `$input-height` |

Many BS3 component variables (panel, navbar, label) have no direct BS5 equivalent. Remove them and handle styling through custom CSS after the import.

- [ ] **Step 4: Fix the `@extend .img-responsive` breakage**

Find `@extend .img-responsive` and change to `@extend .img-fluid`.

- [ ] **Step 5: Verify SCSS compiles**

```bash
rails assets:precompile RAILS_ENV=development
```

This will likely fail on first attempt. Fix compilation errors iteratively — the most common will be references to removed BS3 variables or mixins. Remove or replace them.

- [ ] **Step 6: Run tests**

```bash
rails test
```

Expected: All 162 tests pass. If controller tests fail with template errors, the SCSS compilation is the issue.

- [ ] **Step 7: Commit**

```bash
jj describe -m "Restructure SCSS for Bootstrap 5: variables before imports, rename BS3 → BS5 variables" && jj new
```

---

### Task 3: Update Bootstrap JavaScript require

**Files:**
- Modify: `app/assets/javascripts/application.js`

- [ ] **Step 1: Update the bootstrap require**

The `bootstrap-sass` gem exposed JS via `//= require bootstrap`. The `bootstrap` gem (v5) may use a different path. Check if `//= require bootstrap` still works, or if it needs to be `//= require bootstrap/dist/js/bootstrap.bundle`.

BS5's JS no longer depends on jQuery, but since we keep jQuery for the rest of the app, both can coexist. BS5's bundled JS includes Popper.js.

- [ ] **Step 2: Verify JS loads**

```bash
rails assets:precompile RAILS_ENV=development
```

- [ ] **Step 3: Run tests**

```bash
rails test
```

- [ ] **Step 4: Commit**

```bash
jj describe -m "Update Bootstrap JS require for v5" && jj new
```

---

### Task 4: Migrate navbar

**Files:**
- Modify: `app/views/layouts/_navigation.html.erb`
- Modify: `app/views/layouts/_navigation_links.html.erb`

- [ ] **Step 1: Update _navigation.html.erb**

Class replacements:
- `navbar-default` → `navbar-light bg-light` (or `navbar-dark bg-dark` if dark theme)
- `navbar-fixed-top` → `fixed-top`
- `navbar-toggle` → `navbar-toggler`
- `data-toggle="collapse"` → `data-bs-toggle="collapse"`
- `data-target="#navbar"` → `data-bs-target="#navbar"`
- Remove the 3 `<span class="icon-bar"></span>` lines and replace with `<span class="navbar-toggler-icon"></span>`
- `sr-only` → `visually-hidden`
- `navbar-header` → remove (not needed in BS5; brand goes directly in navbar)

- [ ] **Step 2: Update _navigation_links.html.erb**

- `navbar-right` → `ms-auto`

- [ ] **Step 3: Run tests**

```bash
rails test
```

- [ ] **Step 4: Commit**

```bash
jj describe -m "Migrate navbar to Bootstrap 5 classes" && jj new
```

---

### Task 5: Migrate dropdowns and data attributes

**Files:**
- Modify: `app/views/layouts/_user_links.html.erb`
- Modify: `app/views/layouts/_link_categories.html.erb`
- Modify: `app/views/layouts/_messages.html.erb`
- Modify: `app/views/species/_specieslist.html.erb`
- Modify: `app/views/summary/_author.html.erb`
- Modify: `app/views/shared/_list_categories.html.erb`
- Modify: `app/views/publications/_search_field.html.erb`

- [ ] **Step 1: Replace all data attributes**

Search all `.html.erb` files and replace:
- `data-toggle=` → `data-bs-toggle=`
- `data-dismiss=` → `data-bs-dismiss=`
- `data-target=` → `data-bs-target=`
- `data-parent=` → `data-bs-parent=`

- [ ] **Step 2: Remove `caret` spans**

In `_user_links.html.erb` and `_link_categories.html.erb`, remove `<span class="caret"></span>`. BS5 dropdowns handle the caret with CSS automatically via `.dropdown-toggle::after`.

- [ ] **Step 3: Update responsive visibility classes**

In `_link_categories.html.erb`, `_user_links.html.erb`, and `_link.html.erb`:
- `hidden-sm hidden-md` → `d-none d-lg-inline` (hidden on sm and md, visible on lg+)

Check each usage and pick the correct `d-*` combination for the intended behaviour.

- [ ] **Step 4: Run tests**

```bash
rails test
```

- [ ] **Step 5: Commit**

```bash
jj describe -m "Migrate data attributes, dropdowns, and responsive utilities to Bootstrap 5" && jj new
```

---

### Task 6: Migrate panels to cards

**Files:**
- All files containing `panel` classes (see audit)

- [ ] **Step 1: Find all panel usages**

```bash
grep -rn "panel" app/views/ --include="*.erb" | grep -v "Binary"
```

- [ ] **Step 2: Replace panel classes across all views**

In every file:
- `panel panel-default` → `card`
- `panel-heading` → `card-header`
- `panel-title` → `card-title`
- `panel-body` → `card-body`
- `panel-footer` → `card-footer`
- `panel-collapse collapse` → `collapse` (cards don't use panel-collapse)
- `panel` (standalone) → `card`

Major files to hit:
- `app/views/devise/registrations/_form.html.erb` (5 panels)
- `app/views/publications/index.html.erb`
- `app/views/publications/_search_field.html.erb`
- `app/views/species/_specieslist.html.erb`
- Any stats, summary, or other views with panels

- [ ] **Step 3: Update SCSS panel references**

In `railsbricks_custom.scss`, any custom CSS targeting `.panel` selectors needs to be updated to `.card`.

- [ ] **Step 4: Run tests**

```bash
rails test
```

- [ ] **Step 5: Commit**

```bash
jj describe -m "Migrate panels to cards across all views" && jj new
```

---

### Task 7: Migrate grid classes

**Files:**
- All views using `col-xs-*` and `col-sm-offset-*`

- [ ] **Step 1: Replace col-xs-* with col-***

BS5 removed the `xs` breakpoint. `col-xs-6` becomes `col-6`.

Search and replace across all `.html.erb` files:
- `col-xs-12` → `col-12`
- `col-xs-9` → `col-9`
- `col-xs-8` → `col-8`
- `col-xs-7` → `col-7`
- `col-xs-6` → `col-6`
- `col-xs-5` → `col-5`
- `col-xs-4` → `col-4`
- `col-xs-3` → `col-3`
- `col-xs-2` → `col-2`

- [ ] **Step 2: Replace offset classes**

- `col-sm-offset-3` → `offset-sm-3`

(Only one instance in `app/views/layouts/application.html.erb`)

- [ ] **Step 3: Run tests**

```bash
rails test
```

- [ ] **Step 4: Commit**

```bash
jj describe -m "Migrate grid classes: col-xs-* → col-*, col-sm-offset-* → offset-sm-*" && jj new
```

---

### Task 8: Migrate form-group to mb-3

**Files:**
- 21 view files containing `form-group`

- [ ] **Step 1: Replace form-group across all views**

BS5 removed `form-group`. The replacement is a margin utility like `mb-3`.

Search and replace in all `.html.erb` files:
- `class="form-group"` → `class="mb-3"`
- `"form-group"` → `"mb-3"` (check each occurrence for any compound classes)

Major files (by occurrence count):
- `app/views/devise/registrations/_form.html.erb` (~20)
- `app/views/photos/_form.html.erb` (~19)
- `app/views/devise/registrations/new.html.erb` (~8)
- `app/views/devise/sessions/new.html.erb` (~4)
- `app/views/publications/_form_edit.html.erb` (~12)
- All other form views

- [ ] **Step 2: Run tests**

```bash
rails test
```

- [ ] **Step 3: Commit**

```bash
jj describe -m "Migrate form-group to mb-3 across all form views" && jj new
```

---

### Task 9: Migrate labels to badges and fix bare badges

**Files:**
- Modify: `app/views/publications/_publication_validation.html.erb`
- Modify: `app/views/admin/publications/_publication_validation.html.erb`
- Modify: 12 files with bare `badge` class

- [ ] **Step 1: Replace Bootstrap label components with badges**

In `_publication_validation.html.erb` (both publications/ and admin/publications/):
- `label label-success` → `badge bg-success`
- `label label-info` → `badge bg-info`
- `label label-primary` → `badge bg-primary`
- `label label-warning` → `badge bg-warning text-dark`
- `label label-danger` → `badge bg-danger`

Also fix any dynamic label class variables:
- `"label-warning"` → `"bg-warning text-dark"`
- `"label-success"` → `"bg-success"`
- `"label label-*"` → `"badge bg-*"`

- [ ] **Step 2: Add bg-secondary to bare badges**

In all 12 files with bare `badge` class, add `bg-secondary`:
- `class="badge"` → `class="badge bg-secondary"`

Files:
- `app/views/summary/_author.html.erb`
- `app/views/pages/_memberlist.html.erb`
- `app/views/presentations/_first_author.html.erb`
- `app/views/photos/_photo_metadata.html.erb`
- `app/views/publications/_authors.html.erb`
- `app/views/shared/_member_keyword.html.erb`
- `app/views/shared/_organisation_keyword.html.erb`
- `app/views/species/_specieslist.html.erb`
- `app/views/shared/_item_counts.html.erb`
- `app/views/shared/_list_categories.html.erb`

- [ ] **Step 3: Run tests**

```bash
rails test
```

- [ ] **Step 4: Commit**

```bash
jj describe -m "Migrate BS3 labels to BS5 badges, add bg-secondary to bare badges" && jj new
```

---

### Task 10: Migrate remaining misc classes

**Files:**
- Various views

- [ ] **Step 1: Replace btn-default with btn-secondary**

Search all `.html.erb` files for `btn-default` and replace with `btn-secondary`.

- [ ] **Step 2: Replace sr-only with visually-hidden**

Should already be done in Task 4 (navbar), but verify no other occurrences remain.

- [ ] **Step 3: Verify btn-basic custom class**

The `btn-basic` class in `publications/_search_field.html.erb` is a custom class, not a Bootstrap class. Verify it still renders correctly — it should, since it's defined in our own SCSS.

- [ ] **Step 4: Run tests**

```bash
rails test
```

- [ ] **Step 5: Commit**

```bash
jj describe -m "Migrate remaining BS3 classes: btn-default, sr-only" && jj new
```

---

### Task 11: Generate Kaminari Bootstrap 5 views

**Files:**
- Create: `app/views/kaminari/` (generated by Kaminari)

- [ ] **Step 1: Check if kaminari-bootstrap5 support exists**

The `kaminari` gem may need a theme gem or a manual view generation. Check:

```bash
rails g kaminari:views bootstrap4
```

(BS5 views may not exist as a built-in theme. If not, generate default views and manually update the pagination classes to use BS5's `.pagination`, `.page-item`, `.page-link` classes.)

- [ ] **Step 2: Run tests**

```bash
rails test
```

- [ ] **Step 3: Commit**

```bash
jj describe -m "Generate Kaminari Bootstrap 5 pagination views" && jj new
```

---

### Task 12: Final verification and cleanup

- [ ] **Step 1: Run the full test suite**

```bash
rails test
```

Expected: All 162 tests pass with 0 failures.

- [ ] **Step 2: Search for any remaining BS3 classes**

```bash
grep -rn "panel-default\|panel-heading\|panel-body\|navbar-default\|navbar-fixed-top\|col-xs-\|form-group\|data-toggle\|data-dismiss\|data-target\|data-parent\|btn-default\|label label-\|sr-only\|icon-bar\|navbar-toggle\b\|navbar-right\|hidden-xs\|hidden-sm\|hidden-md\|hidden-lg\|caret" app/views/ --include="*.erb"
```

Fix any stragglers.

- [ ] **Step 3: Search SCSS for BS3 references**

```bash
grep -n "panel\|navbar-default\|img-responsive\|brand-primary\|brand-success\|brand-info\|brand-warning\|brand-danger" app/assets/stylesheets/railsbricks_custom.scss
```

Fix any remaining BS3 variable or class references.

- [ ] **Step 4: Start the server and manually verify key pages**

```bash
rails s
```

Check:
- Homepage (navbar, layout, footer)
- Publications index (search, filters, cards)
- A publication show page
- Sign in / Sign up pages
- Admin dashboard (if accessible)
- Species page (accordion)

- [ ] **Step 5: Commit any final fixes**

```bash
jj describe -m "Fix remaining Bootstrap 3 remnants found in final audit" && jj new
```

- [ ] **Step 6: Set bookmark**

```bash
jj bookmark set ryan/bootstrap-5
```
