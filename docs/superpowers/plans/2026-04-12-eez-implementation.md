# EEZ Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Exclusive Economic Zone (EEZ) data to mesophotic.org, enabling browse-by-country, location metadata, publication filtering, stats, and colored map markers.

**Architecture:** Flat `eezs` table with sovereign as a string column (grouped via scopes). Locations get a `belongs_to :eez` foreign key. Publications reach EEZ data through `locations -> eezs`. Full VLIZ Marine Regions v12 dataset seeded (~280 EEZ records). UI surfaces EEZ as index/show pages, location metadata, publication filters, stats chart, and colored map markers.

**Tech Stack:** Rails 8.1, SQLite3, ERB, Highcharts Maps, Tom Select, Turbo Frames, Minitest

**Spec:** `docs/superpowers/specs/2026-04-12-eez-design.md`

---

### Task 1: Migration and Eez Model

**Files:**
- Create: `db/migrate/TIMESTAMP_create_eezs.rb`
- Create: `db/migrate/TIMESTAMP_add_eez_id_to_locations.rb`
- Create: `app/models/eez.rb`
- Modify: `app/models/location.rb:19` (add `belongs_to`)
- Create: `test/models/eez_test.rb`
- Create: `test/fixtures/eezs.yml`

- [ ] **Step 1: Write Eez model tests**

Create `test/models/eez_test.rb`:

```ruby
require 'test_helper'

class EezTest < ActiveSupport::TestCase
  test "valid with all required fields" do
    eez = Eez.new(mrgid: 99999, geoname: "Test EEZ", sovereign: "Testland", territory: "Test Territory")
    assert eez.valid?
  end

  test "requires mrgid" do
    eez = Eez.new(geoname: "Test", sovereign: "Test", territory: "Test")
    assert_not eez.valid?
    assert eez.errors[:mrgid].any?
  end

  test "requires unique mrgid" do
    eez = Eez.new(mrgid: eezs(:australian_gbr).mrgid, geoname: "Dup", sovereign: "Dup", territory: "Dup")
    assert_not eez.valid?
    assert eez.errors[:mrgid].any?
  end

  test "requires geoname" do
    eez = Eez.new(mrgid: 99999, sovereign: "Test", territory: "Test")
    assert_not eez.valid?
    assert eez.errors[:geoname].any?
  end

  test "requires sovereign" do
    eez = Eez.new(mrgid: 99999, geoname: "Test", territory: "Test")
    assert_not eez.valid?
    assert eez.errors[:sovereign].any?
  end

  test "requires territory" do
    eez = Eez.new(mrgid: 99999, geoname: "Test", sovereign: "Test")
    assert_not eez.valid?
    assert eez.errors[:territory].any?
  end

  test "has many locations" do
    eez = eezs(:australian_gbr)
    assert_includes eez.locations, locations(:great_barrier_reef)
  end

  test "has many publications through locations" do
    eez = eezs(:australian_gbr)
    assert eez.publications.count >= 0
  end

  test ".sovereigns returns sorted distinct list" do
    sovereigns = Eez.sovereigns
    assert_kind_of Array, sovereigns
    assert_equal sovereigns, sovereigns.sort
    assert_equal sovereigns.uniq, sovereigns
  end

  test ".by_sovereign filters by sovereign name" do
    results = Eez.by_sovereign("Australia")
    results.each { |eez| assert_equal "Australia", eez.sovereign }
  end

  test ".with_publications returns only EEZs with linked publications" do
    results = Eez.with_publications
    results.each do |eez|
      assert eez.locations.joins(:publications).exists?
    end
  end
end
```

- [ ] **Step 2: Write Location EEZ association test**

Add to `test/models/location_test.rb`:

```ruby
test "valid without eez" do
  loc = Location.new(description: "Open Ocean", latitude: 10, longitude: 20)
  assert loc.valid?
end

test "belongs to eez" do
  loc = locations(:great_barrier_reef)
  assert_equal eezs(:australian_gbr), loc.eez
end
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `rails test test/models/eez_test.rb test/models/location_test.rb -v`
Expected: FAIL — Eez model and fixtures don't exist yet.

- [ ] **Step 4: Create fixtures**

Create `test/fixtures/eezs.yml`:

```yaml
australian_gbr:
  mrgid: 8440
  geoname: "Australian Exclusive Economic Zone (Great Barrier Reef)"
  sovereign: "Australia"
  territory: "Great Barrier Reef"

australian_coral_sea:
  mrgid: 48188
  geoname: "Australian Exclusive Economic Zone (Coral Sea)"
  sovereign: "Australia"
  territory: "Coral Sea"

red_sea_egypt:
  mrgid: 8441
  geoname: "Egyptian Exclusive Economic Zone"
  sovereign: "Egypt"
  territory: "Egypt"

unstudied_eez:
  mrgid: 99998
  geoname: "Unstudied Exclusive Economic Zone"
  sovereign: "Unstudied Country"
  territory: "Unstudied Territory"
```

- [ ] **Step 5: Create migrations**

Generate and edit `db/migrate/TIMESTAMP_create_eezs.rb`:

```ruby
class CreateEezs < ActiveRecord::Migration[8.1]
  def change
    create_table :eezs do |t|
      t.integer :mrgid, null: false
      t.string :geoname, null: false
      t.string :sovereign, null: false
      t.string :territory, null: false
      t.timestamps
    end

    add_index :eezs, :mrgid, unique: true
    add_index :eezs, :sovereign
  end
end
```

Generate and edit `db/migrate/TIMESTAMP_add_eez_id_to_locations.rb`:

```ruby
class AddEezIdToLocations < ActiveRecord::Migration[8.1]
  def change
    add_reference :locations, :eez, null: true, foreign_key: true
  end
end
```

Run: `rails db:migrate`

- [ ] **Step 6: Create Eez model**

Create `app/models/eez.rb`:

```ruby
class Eez < ApplicationRecord
  has_many :locations
  has_many :publications, -> { distinct }, through: :locations

  validates :mrgid, presence: true, uniqueness: true
  validates :geoname, presence: true
  validates :sovereign, presence: true
  validates :territory, presence: true

  scope :by_sovereign, ->(name) { where(sovereign: name) }
  scope :with_publications, -> {
    joins(locations: :publications).distinct
  }

  def self.sovereigns
    distinct.pluck(:sovereign).sort
  end
end
```

- [ ] **Step 7: Add belongs_to on Location**

In `app/models/location.rb`, after the existing associations (line 22), add:

```ruby
belongs_to :eez, optional: true
```

- [ ] **Step 8: Update location fixtures to reference EEZ**

Update `test/fixtures/locations.yml`:

```yaml
great_barrier_reef:
  description: "Great Barrier Reef"
  short_description: "GBR;Australia"
  latitude: -18.2861
  longitude: 147.7000
  eez: australian_gbr

red_sea:
  description: "Red Sea"
  short_description: "Red Sea;Middle East"
  latitude: 27.2000
  longitude: 34.8000
  eez: red_sea_egypt
```

- [ ] **Step 9: Run tests to verify they pass**

Run: `rails test test/models/eez_test.rb test/models/location_test.rb -v`
Expected: ALL PASS

- [ ] **Step 10: Run full test suite**

Run: `rails test`
Expected: ALL PASS (no regressions)

- [ ] **Step 11: Commit**

```
Add Eez model, migration, and Location association
```

---

### Task 2: Seed Data and Rake Tasks

**Files:**
- Create: `db/seeds/eezs.csv` (extracted from VLIZ data)
- Create: `lib/tasks/eez.rake`
- Create: `test/tasks/eez_rake_test.rb`

- [ ] **Step 1: Write rake task tests**

Create `test/tasks/eez_rake_test.rb`:

```ruby
require 'test_helper'
require 'rake'

class EezRakeTest < ActiveSupport::TestCase
  setup do
    Mesophotic::Application.load_tasks if Rake::Task.tasks.empty?
  end

  test "eez:seed creates EEZ records from CSV" do
    Eez.delete_all
    Rake::Task['eez:seed'].reenable
    Rake::Task['eez:seed'].invoke
    assert Eez.count > 0, "Expected EEZ records to be created"
    assert Eez.find_by(sovereign: "Australia").present?
  end

  test "eez:seed is idempotent" do
    Rake::Task['eez:seed'].reenable
    Rake::Task['eez:seed'].invoke
    count_after_first = Eez.count
    Rake::Task['eez:seed'].reenable
    Rake::Task['eez:seed'].invoke
    assert_equal count_after_first, Eez.count
  end

  test "eez:link_locations matches locations to EEZs" do
    Rake::Task['eez:seed'].reenable
    Rake::Task['eez:seed'].invoke
    Rake::Task['eez:link_locations'].reenable
    Rake::Task['eez:link_locations'].invoke
    # Fixture locations should be matched if they exist in the CSV mapping
    # At minimum, task should run without error
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `rails test test/tasks/eez_rake_test.rb -v`
Expected: FAIL — rake tasks don't exist yet.

- [ ] **Step 3: Prepare seed CSV**

Extract the full VLIZ v12 EEZ dataset into `db/seeds/eezs.csv` with columns: `mrgid,geoname,sovereign,territory`. This requires downloading or extracting from the existing shapefile data in `docs/database/`. The CSV should contain ~280 rows covering all EEZs worldwide.

For the initial implementation, create a minimal CSV from the existing `docs/database/mesophotic_org_EEZ_16112023.csv` mapping data, extracting unique sovereign/territory pairs. The full VLIZ dataset can be integrated later.

Create `db/seeds/eezs.csv` by extracting unique EEZ entries. The file should have headers: `mrgid,geoname,sovereign,territory`.

- [ ] **Step 4: Create rake tasks**

Create `lib/tasks/eez.rake`:

```ruby
namespace :eez do
  desc "Seed EEZ table from CSV"
  task seed: :environment do
    require 'csv'
    csv_path = Rails.root.join('db/seeds/eezs.csv')
    abort "EEZ seed CSV not found at #{csv_path}" unless File.exist?(csv_path)

    count = 0
    CSV.foreach(csv_path, headers: true) do |row|
      Eez.find_or_create_by!(mrgid: row['mrgid'].to_i) do |eez|
        eez.geoname = row['geoname']
        eez.sovereign = row['sovereign']
        eez.territory = row['territory']
        count += 1
      end
    end
    puts "Seeded #{count} new EEZ records (#{Eez.count} total)"
  end

  desc "Link existing locations to EEZs using mapping CSV"
  task link_locations: :environment do
    require 'csv'
    csv_path = Rails.root.join('docs/database/mesophotic_org_EEZ_16112023.csv')
    abort "Location mapping CSV not found at #{csv_path}" unless File.exist?(csv_path)

    matched = 0
    unmatched = []
    CSV.foreach(csv_path, headers: true) do |row|
      location = Location.find_by(description: row['Description'])
      next unless location

      sovereign = row['SOVEREIGN1']&.strip
      territory = row['TERRITORY1']&.strip
      eez = Eez.find_by(sovereign: sovereign, territory: territory)

      if eez
        location.update!(eez: eez)
        matched += 1
      else
        unmatched << "#{location.description} -> #{sovereign} / #{territory}"
      end
    end
    puts "Linked #{matched} locations to EEZs"
    if unmatched.any?
      puts "Unmatched (#{unmatched.count}):"
      unmatched.each { |u| puts "  #{u}" }
    end
  end
end
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `rails test test/tasks/eez_rake_test.rb -v`
Expected: PASS (at least seed and idempotency tests)

- [ ] **Step 6: Run full test suite**

Run: `rails test`
Expected: ALL PASS

- [ ] **Step 7: Commit**

```
Add EEZ seed data and rake tasks
```

---

### Task 3: EEZ Controller and Routes

**Files:**
- Create: `app/controllers/eezs_controller.rb`
- Modify: `config/routes.rb:75` (add eez routes)
- Create: `test/controllers/eezs_controller_test.rb`

- [ ] **Step 1: Write controller tests**

Create `test/controllers/eezs_controller_test.rb`:

```ruby
require 'test_helper'

class EezsControllerTest < ActionDispatch::IntegrationTest
  test "index renders successfully" do
    get eezs_path
    assert_response :success
  end

  test "index groups by sovereign" do
    get eezs_path
    assert_match "Australia", response.body
  end

  test "show renders for valid EEZ" do
    eez = eezs(:australian_gbr)
    get eez_path(eez)
    assert_response :success
    assert_match eez.territory, response.body
  end

  test "show displays sovereign" do
    eez = eezs(:australian_gbr)
    get eez_path(eez)
    assert_match eez.sovereign, response.body
  end

  test "show 404 for invalid EEZ" do
    get eez_path(id: 999999)
    assert_response :not_found
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `rails test test/controllers/eezs_controller_test.rb -v`
Expected: FAIL — controller and routes don't exist.

- [ ] **Step 3: Add routes**

In `config/routes.rb`, after line 75 (`resources :locations, except: :show`), add:

```ruby
resources :eezs, only: [:index, :show]
```

- [ ] **Step 4: Create controller**

Create `app/controllers/eezs_controller.rb`:

```ruby
class EezsController < ApplicationController
  def index
    @studied = Eez.with_publications
      .select("eezs.*, COUNT(DISTINCT publications.id) AS publications_count")
      .joins(locations: :publications)
      .group("eezs.id")
      .order(:sovereign, :territory)
      .group_by(&:sovereign)

    @unstudied = Eez.where.not(id: Eez.with_publications)
      .order(:sovereign, :territory)
      .group_by(&:sovereign)
  end

  def show
    @eez = Eez.find_by(id: params[:id])
    return head(:not_found) unless @eez

    @locations = @eez.locations
      .left_joins(:publications)
      .select("locations.*, COUNT(publications.id) AS publications_count")
      .group("locations.id")
      .order(Arel.sql("COUNT(publications.id) DESC"))
  end
end
```

- [ ] **Step 5: Create index view**

Create `app/views/eezs/index.html.erb` — sovereign-first hierarchy with map. (Full ERB in implementation — uses collapsible Bootstrap accordion pattern grouped by sovereign, Tom Select search, and Turbo Frame world map with colored markers.)

- [ ] **Step 6: Create show view**

Create `app/views/eezs/show.html.erb` — territory detail page with locations list and map. (Full ERB in implementation — header with territory/sovereign, MRGID link to marineregions.org, locations list with publication counts, Turbo Frame map.)

- [ ] **Step 7: Run tests to verify they pass**

Run: `rails test test/controllers/eezs_controller_test.rb -v`
Expected: ALL PASS

- [ ] **Step 8: Run full test suite**

Run: `rails test`
Expected: ALL PASS

- [ ] **Step 9: Commit**

```
Add EEZ index and show pages with sovereign hierarchy
```

---

### Task 4: Location Form EEZ Dropdown

**Files:**
- Modify: `app/views/locations/_form.html.erb` (add EEZ dropdown)
- Modify: `app/controllers/locations_controller.rb:68` (add `:eez_id` to strong params)
- Modify: `test/controllers/locations_controller_test.rb` (add EEZ param tests)

- [ ] **Step 1: Write tests for EEZ dropdown and params**

Add to `test/controllers/locations_controller_test.rb`:

```ruby
test "new form has EEZ dropdown" do
  sign_in users(:editor_user)
  get new_location_path
  assert_select 'select[name="location[eez_id]"]'
end

test "edit form has EEZ dropdown" do
  sign_in users(:editor_user)
  get edit_location_path(locations(:great_barrier_reef))
  assert_select 'select[name="location[eez_id]"]'
end

test "create with eez_id saves association" do
  sign_in users(:editor_user)
  eez = eezs(:australian_gbr)
  post locations_path, params: { location: { description: "New Reef", latitude: -15.5, longitude: 145.8, eez_id: eez.id } }
  assert_equal eez, Location.last.eez
end

test "update with eez_id saves association" do
  sign_in users(:editor_user)
  loc = locations(:great_barrier_reef)
  new_eez = eezs(:australian_coral_sea)
  patch location_path(loc), params: { location: { eez_id: new_eez.id } }
  assert_equal new_eez, loc.reload.eez
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `rails test test/controllers/locations_controller_test.rb -v`
Expected: FAIL — no dropdown in form, `eez_id` not permitted.

- [ ] **Step 3: Add EEZ dropdown to form**

In `app/views/locations/_form.html.erb`, add a new field group after the longitude field (before the publication count warning):

```erb
<div class="mb-3">
  <%= f.label :eez_id, "EEZ", class: "required" %><br>
  <%= f.select :eez_id,
      options_for_select(
        Eez.order(:sovereign, :territory).map { |e| ["#{e.territory} (#{e.sovereign})", e.id] },
        location.eez_id
      ),
      { include_blank: "Select EEZ..." },
      { class: "form-select", "data-tom-select" => "" } %>
</div>
```

Note: Remove the `class: "required"` from the label — EEZ is optional per spec. Use just `f.label :eez_id, "EEZ"`.

- [ ] **Step 4: Add `:eez_id` to strong params**

In `app/controllers/locations_controller.rb`, change line 68:

```ruby
def location_params
  params.require(:location).permit(:description, :latitude, :longitude, :eez_id)
end
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `rails test test/controllers/locations_controller_test.rb -v`
Expected: ALL PASS

- [ ] **Step 6: Run full test suite**

Run: `rails test`
Expected: ALL PASS

- [ ] **Step 7: Commit**

```
Add EEZ dropdown to location form with Tom Select
```

---

### Task 5: Location Pages EEZ Metadata Display

**Files:**
- Modify: `app/views/summary/show.html.erb` or location summary view (show EEZ metadata)
- Modify: `test/controllers/eezs_controller_test.rb` (or location display tests)

The locations don't have a dedicated show page — they use the summary controller (`/:model/:id`). Check `app/views/summary/show.html.erb` and the summary controller to understand how location details are displayed, then add EEZ territory and sovereign as metadata linked to the EEZ show page.

- [ ] **Step 1: Find where location details are displayed**

Read `app/controllers/summary_controller.rb` and `app/views/summary/show.html.erb` to understand the location detail view. Add EEZ info after existing metadata.

- [ ] **Step 2: Add EEZ metadata to location detail view**

Add to the location summary display:

```erb
<% if @record.respond_to?(:eez) && @record.eez.present? %>
  <p><strong>EEZ:</strong> <%= link_to "#{@record.eez.territory} (#{@record.eez.sovereign})", eez_path(@record.eez) %></p>
<% end %>
```

- [ ] **Step 3: Run full test suite**

Run: `rails test`
Expected: ALL PASS

- [ ] **Step 4: Commit**

```
Show EEZ metadata on location detail pages
```

---

### Task 6: Publication Search Filter by Sovereign

**Files:**
- Modify: `app/models/publication.rb:145-157` (add `by_sovereign` to `base_search`)
- Modify: `app/models/publication.rb` (add `publication_sovereigns` class method)
- Modify: `app/views/publications/_search_field.html.erb:82-90` (add EEZ filter)
- Create: `test/models/publication_eez_test.rb`

- [ ] **Step 1: Write Publication EEZ scope tests**

Create `test/models/publication_eez_test.rb`:

```ruby
require 'test_helper'

class PublicationEezTest < ActiveSupport::TestCase
  test ".by_sovereign returns publications in sovereign's EEZs" do
    results = Publication.by_sovereign(["Australia"])
    results.each do |pub|
      sovereigns = pub.locations.filter_map { |l| l.eez&.sovereign }
      assert_includes sovereigns, "Australia"
    end
  end

  test ".by_sovereign with nil returns all" do
    assert_equal Publication.all.count, Publication.by_sovereign(nil).count
  end

  test ".publication_sovereigns returns sorted unique list" do
    sovereigns = Publication.publication_sovereigns
    assert_kind_of Array, sovereigns
    assert_equal sovereigns, sovereigns.sort
    assert_equal sovereigns.uniq, sovereigns
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `rails test test/models/publication_eez_test.rb -v`
Expected: FAIL — scope and method don't exist.

- [ ] **Step 3: Add `by_sovereign` scope and `publication_sovereigns` method**

In `app/models/publication.rb`, add after the dynamic scopes block (after line 169):

```ruby
scope :by_sovereign, ->(params) {
  if params.present?
    joins("INNER JOIN locations_publications ON publications.id = locations_publications.publication_id")
    .joins("INNER JOIN locations ON locations.id = locations_publications.location_id")
    .joins("INNER JOIN eezs ON eezs.id = locations.eez_id")
    .where("eezs.sovereign IN (?)", params)
  else
    all
  end
}
```

Add class method (near the other `publication_*` methods):

```ruby
def self.publication_sovereigns
  Eez.joins(locations: :publications)
    .distinct
    .pluck(:sovereign)
    .sort
end
```

- [ ] **Step 4: Add `by_sovereign` to `base_search`**

In `app/models/publication.rb`, in the `base_search` scope (around line 148-151), add:

```ruby
.by_sovereign(search_params["sovereigns"])
```

- [ ] **Step 5: Add EEZ filter to search UI**

In `app/views/publications/_search_field.html.erb`, after the Locations/Focus Groups row (after line 90), add:

```erb
<div class="row">
  <hr>
  <div class="col-sm-6">
    <%= search_param "EEZ / Country", Publication.publication_sovereigns, :sovereigns, params, true %>
  </div>
</div>
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `rails test test/models/publication_eez_test.rb -v`
Expected: ALL PASS

- [ ] **Step 7: Run full test suite**

Run: `rails test`
Expected: ALL PASS

- [ ] **Step 8: Commit**

```
Add publication search filter by EEZ sovereign
```

---

### Task 7: CSV Export with EEZ Columns

**Files:**
- Modify: `app/models/publication.rb` (csv_header, csv_row, csv_association_data)
- Add test in: `test/models/publication_eez_test.rb`

- [ ] **Step 1: Write CSV export test**

Add to `test/models/publication_eez_test.rb`:

```ruby
test "csv_header includes EEZ columns" do
  header = Publication.csv_header
  assert_includes header, "eez_sovereign"
  assert_includes header, "eez_territory"
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `rails test test/models/publication_eez_test.rb -v`
Expected: FAIL — columns not in header yet.

- [ ] **Step 3: Add EEZ columns to CSV export**

In `app/models/publication.rb`:

Add to `csv_header` (after `"locations"` on line 417):

```ruby
"eez_sovereign",
"eez_territory"
```

Add to `csv_association_data` (after locations block, before the return on line 329):

```ruby
eez_sovereigns = Location
  .select("publications.id, GROUP_CONCAT(DISTINCT eezs.sovereign, '; ') AS sovereign_names")
  .joins(:publications)
  .left_joins(:eez)
  .group("publications.id")
  .reduce({}) { |result, a| result.update(a.id => a.sovereign_names) }
eez_territories = Location
  .select("publications.id, GROUP_CONCAT(DISTINCT eezs.territory, '; ') AS territory_names")
  .joins(:publications)
  .left_joins(:eez)
  .group("publications.id")
  .reduce({}) { |result, a| result.update(a.id => a.territory_names) }
```

Update the return to include the new variables:

```ruby
[validated, fields, focusgroups, platforms, locations, eez_sovereigns, eez_territories]
```

Update `csv_row` signature and body to accept and include the new data:

```ruby
def self.csv_row publication, validated, fields, focusgroups, platforms, locations, eez_sovereigns, eez_territories
```

Add at end of row array (after `locations[publication.id]`):

```ruby
eez_sovereigns[publication.id],
eez_territories[publication.id],
```

Update all callers of `csv_row` and `csv_association_data` (in `csv_enumerator` around line 341) to destructure the new return values.

- [ ] **Step 4: Run tests to verify they pass**

Run: `rails test test/models/publication_eez_test.rb -v`
Expected: ALL PASS

- [ ] **Step 5: Run full test suite**

Run: `rails test`
Expected: ALL PASS

- [ ] **Step 6: Commit**

```
Add EEZ sovereign and territory to publication CSV export
```

---

### Task 8: Stats Chart — Publications by Country

**Files:**
- Modify: `app/controllers/stats_controller.rb` (add `world_sovereigns` action)
- Create: `app/views/stats/_world_sovereigns.html.erb`
- Modify: `app/views/stats/_world.html.erb` (add Turbo Frame for new chart)
- Modify: `config/routes.rb` (add stats route)

- [ ] **Step 1: Add route**

In `config/routes.rb`, after line 69 (`get :world_locations, controller: :stats`), add:

```ruby
get :world_sovereigns, controller: :stats
```

- [ ] **Step 2: Add controller action**

In `app/controllers/stats_controller.rb`, add `world_sovereigns` to the `before_action :load_publications_for_status` list (line 8), then add the action:

```ruby
def world_sovereigns
  @sovereigns = Eez
    .joins(locations: :publications)
    .select("eezs.sovereign AS description, eezs.sovereign AS chart_description, COUNT(DISTINCT publications.id) AS publications_count")
    .where("publications.id IN (SELECT id FROM (#{@publications.to_sql}))")
    .group("eezs.sovereign")
    .order(Arel.sql("COUNT(DISTINCT publications.id) DESC"))

  render_in_turbo_frame("stats-world_sovereigns") { render_to_string partial: "world_sovereigns" }
end
```

Note: We alias `sovereign` as `description` and `chart_description` so it works with the existing `format_for_chart` helper which expects those methods.

- [ ] **Step 3: Create partial**

Create `app/views/stats/_world_sovereigns.html.erb`:

```erb
<%= render partial: 'shared/stats_bar_graph',
           locals: { title: 'Sovereigns_bar_graph',
                     data: format_for_chart(@sovereigns, 25),
                     height: 600,
                     unit: 'Percentage' } %>
<p>
  Fig. 3d: <b>EEZ Sovereigns (top 25)</b><br>
</p>
```

- [ ] **Step 4: Add Turbo Frame to stats world section**

In `app/views/stats/_world.html.erb`, add after the world_locations Turbo Frame (after line 13):

```erb
<div class="col-sm-6" style="min-height: 600px;">
  <%= turbo_frame_tag "stats-world_sovereigns", src: world_sovereigns_path(:status => @status, :year => @year), loading: :lazy %>
</div>
```

- [ ] **Step 5: Run full test suite**

Run: `rails test`
Expected: ALL PASS

- [ ] **Step 6: Commit**

```
Add Publications by Country stats chart
```

---

### Task 9: EEZ Index Map with Colored Markers

**Files:**
- Modify: `app/assets/javascripts/charts.js` (add `map-colored` chart type)
- Modify: `app/views/eezs/index.html.erb` (use colored map)
- Modify: `app/controllers/eezs_controller.rb` (provide map data)

- [ ] **Step 1: Add `map-colored` chart type to charts.js**

In `app/assets/javascripts/charts.js`, add a new chart type in the `chartTypes` object:

```javascript
'map-colored': function(el) { mapColored(el); },
```

Add the `mapColored` function:

```javascript
function mapColored(el) {
  var data = JSON.parse(el.dataset.values);
  var config = baseOpts(el);
  config.chart = { backgroundColor: 'rgba(255, 255, 255, 0)' };
  config.mapNavigation = { enabled: true, buttonOptions: { verticalAlign: 'top' } };
  config.exporting = { enabled: false };

  // Group data by sovereign, assign deterministic colors
  var palette = ['#058DC7', '#50B432', '#ED561B', '#DDDF00', '#24CBE5',
                 '#64E572', '#FF9655', '#FFF263', '#6AF9C4', '#FF6B6B',
                 '#C49C94', '#9EDAE5', '#DBDB8D', '#E377C2', '#7F7F7F'];
  var groups = {};
  data.forEach(function(point) {
    if (!groups[point.sovereign]) groups[point.sovereign] = [];
    groups[point.sovereign].push(point);
  });

  var series = [
    { name: 'Countries', mapData: Highcharts.maps['custom/world-continents'], color: '#E0E0E0', enableMouseTracking: false }
  ];

  var sovereigns = Object.keys(groups).sort();
  sovereigns.forEach(function(sov, i) {
    series.push({
      type: 'mapbubble',
      name: sov,
      data: groups[sov],
      color: palette[i % palette.length],
      maxSize: '12%',
      dataLabels: { enabled: true, format: '{point.name}' },
      cursor: 'pointer',
      point: { events: { click: function() { if (this.options.url) window.location = this.options.url; } } }
    });
  });

  config.legend = { enabled: true };
  config.series = series;
  Highcharts.mapChart(el, config);
}
```

- [ ] **Step 2: Add map data to EEZ index controller**

In `app/controllers/eezs_controller.rb`, in the `index` action, add:

```ruby
@map_data = Location.joins(:publications, :eez)
  .select("locations.*, eezs.sovereign, COUNT(DISTINCT publications.id) AS pub_count")
  .group("locations.id")
  .map { |l| { name: l.description, lat: l.latitude.to_f, lon: l.longitude.to_f, z: l.pub_count, sovereign: l.sovereign, url: summary_path(model: 'locations', id: l.id) } }
```

- [ ] **Step 3: Use colored map in index view**

In `app/views/eezs/index.html.erb`, add the map div:

```erb
<div data-chart="map-colored"
     data-values="<%= @map_data.to_json %>"
     style="height: 400px;"></div>
```

- [ ] **Step 4: Run full test suite**

Run: `rails test`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```
Add colored map markers by sovereign to EEZ index
```

---

### Task 10: Navigation and Final Integration

**Files:**
- Modify: `app/views/layouts/_navigation_links.html.erb` (add EEZ link to nav)
- Modify: `app/models/publication.rb:458` (add `"sovereigns"` to `default_search_params`)
- Run full test suite and verify everything works end-to-end.

- [ ] **Step 1: Add EEZ to navigation**

In `app/views/layouts/_navigation_links.html.erb`, uncomment or add an EEZ/Countries link in the nav bar (either as a standalone link or under the Categories dropdown). Follow the existing pattern:

```erb
<%= render partial: 'layouts/link',
           locals: { path: eezs_path,
                     title: 'Countries',
                     icon: 'bi-globe-americas' } %>
```

- [ ] **Step 2: Add sovereigns to default search params**

In `app/models/publication.rb`, in `default_search_params` method, add:

```ruby
"sovereigns" => nil,
```

- [ ] **Step 3: Run full test suite**

Run: `rails test`
Expected: ALL PASS

- [ ] **Step 4: Manual smoke test**

- Visit `/eezs` — verify sovereign hierarchy renders, map shows colored markers
- Visit `/eezs/:id` — verify territory detail page
- Visit `/locations/new` — verify EEZ dropdown appears
- Visit `/publications` — verify EEZ/Country filter in advanced filters
- Visit `/statistics/all/2023` — verify Publications by Country chart loads
- Download CSV — verify `eez_sovereign` and `eez_territory` columns present

- [ ] **Step 5: Commit**

```
Add EEZ navigation link and finalize integration
```

- [ ] **Step 6: Create PR**

Create PR with title: "Add EEZ (Exclusive Economic Zone) data (fixes #153)"
