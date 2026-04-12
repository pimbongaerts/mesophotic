# EEZ (Exclusive Economic Zone) Feature Design

**GitHub Issue:** #153
**Date:** 2026-04-12

## Overview

Add EEZ (Exclusive Economic Zone) data to mesophotic.org, enabling users to browse research by sovereign nation and territory, view EEZ metadata on locations, filter publications by country, and see EEZ-aware stats and maps.

## Data Source

The canonical source is the **VLIZ Marine Regions v12** dataset (~280 EEZ records worldwide). The project already has a prepared mapping CSV (`docs/database/mesophotic_org_EEZ_16112023.csv`) that links existing locations to their EEZ sovereign and territory.

We store the `MRGID` (Marine Regions ID) per EEZ as a stable foreign key for future boundary polygon integration.

## Data Model

### Approach: Flat EEZ table with sovereign as virtual grouping

A single `eezs` table. Sovereign is a string column — grouping/filtering is done via scopes. No separate sovereigns table (YAGNI — can be extracted later if sovereign-level metadata is needed).

### `eezs` table

| Column     | Type    | Notes                                                        |
|------------|---------|--------------------------------------------------------------|
| `id`       | integer | PK                                                           |
| `mrgid`    | integer | VLIZ Marine Regions ID, unique, indexed                      |
| `geoname`  | string  | Full EEZ name (e.g., "Australian Exclusive Economic Zone")   |
| `sovereign`| string  | Sovereign nation (e.g., "Australia"), indexed                 |
| `territory`| string  | Territory name (e.g., "Coral Sea")                           |
| timestamps |         | created_at, updated_at                                       |

### `locations` table change

- Add `eez_id` (integer, nullable foreign key, indexed)

### Associations

```ruby
# Eez
has_many :locations
has_many :publications, -> { distinct }, through: :locations

# Location
belongs_to :eez, optional: true
```

`optional: true` because existing locations won't all be mapped immediately, and some research locations (e.g., international waters) may not fall in any EEZ.

### Scopes on Eez

- `Eez.sovereigns` — `distinct.pluck(:sovereign).sort`
- `Eez.by_sovereign(name)` — `where(sovereign: name)`
- `Eez.with_publications` — only EEZs that have locations with publications

## UI

### 1. EEZ Index Page (`/eezs`)

**Layout:** Sovereign-first hierarchy list on the left, world map on the right.

**List panel:**
- Grouped by sovereign, sorted alphabetically
- Each sovereign is a collapsible header showing: name + total publication count across all its territories
- Under each sovereign, territories listed with their own publication count
- Sovereigns with no linked publications shown in a muted/collapsed "Unstudied" section at the bottom (full dataset is seeded)
- Tom Select search at the top to jump to a sovereign or territory

**Map panel:**
- World map with location markers color-coded by sovereign + legend
- Clicking a marker links to the location page

### 2. EEZ Show Page (`/eezs/:id`)

- Header: territory name, sovereign shown as subtitle/badge
- MRGID linking out to the Marine Regions page for that EEZ
- List of locations within this EEZ, each with publication count
- Map zoomed to show just this EEZ's locations with markers
- Stats summary: total publications, top species/fields studied

### 3. Location Pages

- Location detail/edit pages show EEZ territory and sovereign as metadata, e.g., "EEZ: Coral Sea (Australia)" — linked to the EEZ show page
- Admin edit form: Tom Select dropdown for EEZ assignment (searchable by territory and sovereign)
- Admin new form: same dropdown

### 4. Publication Integration

- CSV export: add `eez_sovereign` and `eez_territory` columns
- Publication search/filters: add "EEZ / Country" to advanced filters — Tom Select multi-select dropdown listing sovereigns with territory count, e.g., "Australia (7 territories)"
- Filtering by sovereign returns publications linked to any location in any of that sovereign's EEZs
- Implemented as a scope on Publication: `.by_sovereign(names)` — joins through locations -> eezs

### 5. Stats Page

- New "Publications by Country" horizontal bar chart (top 25 sovereigns)
- Same Highcharts pattern as existing stats charts
- Query: join publications -> locations -> eezs, group by sovereign, count distinct publications

### 6. Maps

- EEZ index map: location markers color-coded by sovereign + legend. Colors assigned via a deterministic palette (consistent color per sovereign across page loads).
- EEZ show page map: zoomed to that EEZ's locations
- Locations index map: unchanged
- Map boundary overlays: **deferred** to a future phase. MRGID stored now for future linking.

**Routing:** `resources :eezs, only: [:index, :show]` — no public create/edit. Admin edits through RailsAdmin.

**Strong params:** Location `location_params` adds `:eez_id`.

## Seed Data & Admin

### Seed data

- Full VLIZ Marine Regions v12 dataset (~280 EEZ records)
- Delivered as a CSV seed file in `db/seeds/`
- Idempotent — upsert by MRGID, safe to re-run

### Linking existing locations

- Use prepared `mesophotic_org_EEZ_16112023.csv` to match existing locations by description -> set `eez_id`
- Rake tasks: `rake eez:seed` (load EEZ table) and `rake eez:link_locations` (match locations to EEZs)
- Unmatched locations get `eez_id: nil` — admin can assign manually

### Admin workflow

- EEZ records managed through RailsAdmin (reference data, no custom CRUD)
- Location forms get a Tom Select dropdown for EEZ assignment

## Testing

### Model tests (Eez)

- Validations: requires mrgid (unique), geoname, sovereign, territory
- Associations: `has_many :locations`, `has_many :publications, through: :locations`
- Scopes: `.sovereigns`, `.by_sovereign(name)`, `.with_publications`

### Model tests (Location)

- `belongs_to :eez, optional: true` — location valid without EEZ
- `location.eez` returns associated EEZ

### Controller tests (EezsController)

- Index renders successfully, groups by sovereign
- Show renders for a valid EEZ, shows linked locations
- 404 for invalid EEZ id

### Controller tests (LocationsController)

- Create/update with `eez_id` param saves association
- Form renders EEZ dropdown

### Integration/scope tests

- `Publication.by_sovereign("Australia")` returns correct publications
- EEZ with no locations returns zero publication count
- CSV export includes EEZ columns

### Seed task tests

- `eez:seed` creates expected number of records
- `eez:link_locations` matches locations correctly
- Re-running seed is idempotent

## Deferred / Future Work

- **Map boundary overlays:** EEZ boundary polygons from VLIZ shapefile or WMS service. MRGID stored now as the linking key.
- **Auto-suggest EEZ from coordinates:** Point-in-polygon lookup against boundary data when admin enters lat/lon. Requires boundary data.
- **Sovereign table extraction:** If sovereign-level metadata (ISO codes, flags, UN codes) is needed, extract from string column to its own table.
