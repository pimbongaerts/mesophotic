# User Role Consolidation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the `admin` and `editor` boolean columns with a single `role` string column where admin is a strict superset of editor.

**Architecture:** Add a `role` column, migrate data, update model methods to maintain the same interface (`admin?`, `editor?`, `editor_or_admin?`), update views/controllers, remove old columns. The method signatures don't change so most call sites need no modification.

**Tech Stack:** Rails 6.1, SQLite3

**VCS:** jj. Work on bookmark `ryan/user-roles`.

---

## File Structure

**New files:**
- `db/migrate/TIMESTAMP_consolidate_user_roles.rb` — single migration: add role, populate, remove admin/editor

**Modified files:**
- `app/models/user.rb` — role methods, scopes, schema annotation
- `app/controllers/application_controller.rb` — fix `@current_user` bug
- `app/controllers/admin/users_controller.rb` — strong params, update logic
- `app/views/admin/users/edit.html.erb` — role dropdown instead of checkboxes
- `app/views/admin/users/index.html.erb` — simplified role badge
- `app/views/devise/registrations/_form.html.erb` — role dropdown instead of checkboxes
- `test/fixtures/users.yml` — role column
- `test/models/user_test.rb` — updated role tests

---

### Task 1: Add migration

**Files:**
- Create: `db/migrate/TIMESTAMP_consolidate_user_roles.rb`

- [ ] **Step 1: Generate migration**

```bash
rails generate migration ConsolidateUserRoles
```

- [ ] **Step 2: Write the migration**

Replace the generated migration content with:

```ruby
class ConsolidateUserRoles < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :role, :string, default: "member", null: false

    # Populate from existing booleans (admin takes precedence)
    execute "UPDATE users SET role = 'admin' WHERE admin = 1"
    execute "UPDATE users SET role = 'editor' WHERE editor = 1 AND admin = 0"

    remove_column :users, :admin
    remove_column :users, :editor
  end

  def down
    add_column :users, :admin, :boolean, default: false, null: false
    add_column :users, :editor, :boolean, default: false

    execute "UPDATE users SET admin = 1 WHERE role = 'admin'"
    execute "UPDATE users SET editor = 1 WHERE role = 'editor'"

    remove_column :users, :role
  end
end
```

- [ ] **Step 3: Run migration**

```bash
rails db:migrate
```

- [ ] **Step 4: Commit**

```bash
jj describe -m "Add migration: consolidate admin/editor booleans into single role column" && jj new
```

---

### Task 2: Update User model

**Files:**
- Modify: `app/models/user.rb`

- [ ] **Step 1: Update schema annotation**

Replace the `admin` and `editor` lines in the schema comment (lines 8 and 42) with:

```
#  role                         :string           default("member"), not null
```

Remove:
```
#  admin                        :boolean          default(FALSE), not null
```
and:
```
#  editor                       :boolean          default(FALSE)
```

- [ ] **Step 2: Replace `editor_or_admin?` method**

Replace lines 118-120:

```ruby
  def editor_or_admin?
    editor || admin
  end
```

with:

```ruby
  def admin?
    role == "admin"
  end

  def editor?
    role.in?(["editor", "admin"])
  end

  def editor_or_admin?
    editor?
  end
```

- [ ] **Step 3: Update `users_count` scope**

Replace line 113-115:

```ruby
  def self.users_count
    where('admin = ? AND locked = ?', false, false).count
  end
```

with:

```ruby
  def self.users_count
    where.not(role: "admin").where(locked: false).count
  end
```

- [ ] **Step 4: Update ordering scopes**

Replace line 91-102:

```ruby
  def self.paged(page_number)
    order(admin: :desc, email: :asc).page page_number
  end

  def self.search_and_order(search, page_number)
    if search
      where('email LIKE ?', '%#{search.downcase}%')
        .order(admin: :desc, email: :asc).page page_number
    else
      order(admin: :desc, email: :asc).page page_number
    end
  end
```

with:

```ruby
  def self.paged(page_number)
    order(Arel.sql("CASE role WHEN 'admin' THEN 0 WHEN 'editor' THEN 1 ELSE 2 END"), email: :asc).page page_number
  end

  def self.search_and_order(search, page_number)
    if search
      where('email LIKE ?', '%#{search.downcase}%')
        .order(Arel.sql("CASE role WHEN 'admin' THEN 0 WHEN 'editor' THEN 1 ELSE 2 END"), email: :asc).page page_number
    else
      order(Arel.sql("CASE role WHEN 'admin' THEN 0 WHEN 'editor' THEN 1 ELSE 2 END"), email: :asc).page page_number
    end
  end
```

- [ ] **Step 5: Run tests**

```bash
rails test
```

Expected: Some failures (fixtures still use old columns). That's fine — we fix them in Task 5.

- [ ] **Step 6: Commit**

```bash
jj describe -m "Update User model: role column methods, scopes, and annotation" && jj new
```

---

### Task 3: Fix application controller

**Files:**
- Modify: `app/controllers/application_controller.rb`

- [ ] **Step 1: Fix the `@current_user` bug and simplify `require_admin_or_editor!`**

Replace lines 89-98:

```ruby
  # Only permits editor users
  def require_admin_or_editor!
    authenticate_user!

    if current_user && !current_user.editor? && !@current_user.admin?
      redirect_to root_path
    end
  end

  helper_method :require_admin_or_editor!
```

with:

```ruby
  # Only permits editor or admin users
  def require_admin_or_editor!
    authenticate_user!

    if current_user && !current_user.editor?
      redirect_to root_path
    end
  end

  helper_method :require_admin_or_editor!
```

This fixes the `@current_user` bug and simplifies the check — `editor?` already returns true for admins.

- [ ] **Step 2: Commit**

```bash
jj describe -m "Fix require_admin_or_editor!: use current_user, simplify with editor? (includes admin)" && jj new
```

---

### Task 4: Update admin users controller and views

**Files:**
- Modify: `app/controllers/admin/users_controller.rb`
- Modify: `app/views/admin/users/edit.html.erb`
- Modify: `app/views/admin/users/index.html.erb`

- [ ] **Step 1: Update strong params and update logic in controller**

In `app/controllers/admin/users_controller.rb`, replace lines 29-33 in the update method:

```ruby
    if current_user.id != @user.id
      @user.admin = (new_params[:admin] == "1") if new_params.key?(:admin)
      @user.editor = (new_params[:editor] == "1") if new_params.key?(:editor)
      @user.locked = (new_params[:locked] == "1" || new_params[:locked] == "true") if new_params.key?(:locked)
    end
```

with:

```ruby
    if current_user.id != @user.id
      @user.role = new_params[:role] if new_params.key?(:role) && new_params[:role].in?(["member", "editor", "admin"])
      @user.locked = (new_params[:locked] == "1" || new_params[:locked] == "true") if new_params.key?(:locked)
    end
```

In `user_params`, replace `:admin` with `:role` and add `:editor` removal. Replace line 69:

```ruby
    :admin,
```

with:

```ruby
    :role,
```

- [ ] **Step 2: Update edit form — replace checkboxes with dropdown**

In `app/views/admin/users/edit.html.erb`, replace lines 31-43:

```erb
          <% unless current_user.id == @user.id %>
            <hr>
            <div class="mb-3">
              <div class="form-check">
                <%= f.check_box :admin, class: "form-check-input" %>
                <%= f.label :admin, "Admin", class: "form-check-label" %>
              </div>
              <div class="form-check">
                <%= f.check_box :editor, class: "form-check-input" %>
                <%= f.label :editor, "Editor", class: "form-check-label" %>
              </div>
            </div>
          <% end %>
```

with:

```erb
          <% unless current_user.id == @user.id %>
            <hr>
            <div class="mb-3">
              <%= f.label :role, class: "form-label" %>
              <%= f.select :role, [["Member", "member"], ["Editor", "editor"], ["Admin", "admin"]], {}, class: "form-select" %>
            </div>
          <% end %>
```

- [ ] **Step 3: Update edit sidebar role badges**

In `app/views/admin/users/edit.html.erb`, replace lines 86-89:

```erb
          <% if @user.admin? %><span class="badge bg-danger">Admin</span><% end %>
          <% if @user.editor? %><span class="badge bg-info">Editor</span><% end %>
          <% if @user.locked? %><span class="badge bg-warning text-dark">Locked</span><% end %>
          <% if !@user.admin? && !@user.editor? && !@user.locked? %><span class="badge bg-secondary">Member</span><% end %>
```

with:

```erb
          <% case @user.role %>
            <% when "admin" %><span class="badge bg-danger">Admin</span>
            <% when "editor" %><span class="badge bg-info">Editor</span>
            <% else %><span class="badge bg-secondary">Member</span>
          <% end %>
          <% if @user.locked? %><span class="badge bg-warning text-dark">Locked</span><% end %>
```

- [ ] **Step 4: Update index table role badges**

In `app/views/admin/users/index.html.erb`, replace lines 35-38:

```erb
              <% if user.admin? %><span class="badge bg-danger">Admin</span><% end %>
              <% if user.editor? %><span class="badge bg-info">Editor</span><% end %>
              <% if user.locked? %><span class="badge bg-warning text-dark">Locked</span><% end %>
              <% if !user.admin? && !user.editor? && !user.locked? %><span class="badge bg-secondary">Member</span><% end %>
```

with:

```erb
              <% case user.role %>
                <% when "admin" %><span class="badge bg-danger">Admin</span>
                <% when "editor" %><span class="badge bg-info">Editor</span>
                <% else %><span class="badge bg-secondary">Member</span>
              <% end %>
              <% if user.locked? %><span class="badge bg-warning text-dark">Locked</span><% end %>
```

- [ ] **Step 5: Commit**

```bash
jj describe -m "Update admin user management: role dropdown, simplified badges, strong params" && jj new
```

---

### Task 5: Update Devise registration form

**Files:**
- Modify: `app/views/devise/registrations/_form.html.erb`

- [ ] **Step 1: Replace admin/editor checkboxes with role dropdown**

In `app/views/devise/registrations/_form.html.erb`, replace lines 27-31:

```erb
                <% if current_user.try(:admin?) %>
                  <%= f.check_box :editor %>
                  <%= f.label :editor %>&nbsp;&nbsp;&nbsp;
                  <%= f.check_box :admin %>
                  <%= f.label :admin %>
```

with:

```erb
                <% if current_user.try(:admin?) %>
                  <%= f.label :role %>&nbsp;
                  <%= f.select :role, [["Member", "member"], ["Editor", "editor"], ["Admin", "admin"]], {}, class: "form-select form-select-sm", style: "width: auto; display: inline-block;" %>
```

- [ ] **Step 2: Commit**

```bash
jj describe -m "Update Devise registration form: role dropdown instead of checkboxes" && jj new
```

---

### Task 6: Update fixtures and tests

**Files:**
- Modify: `test/fixtures/users.yml`
- Modify: `test/models/user_test.rb`

- [ ] **Step 1: Update fixtures**

Replace the entire `test/fixtures/users.yml` with:

```yaml
admin_user:
  email: "admin@example.com"
  encrypted_password: "$2a$10$qtbdzaGgpA2uZTngMjo1eudRHECv33iprWF7NWWL.gTMQ.V4/q3ey"
  first_name: "Admin"
  last_name: "User"
  role: "admin"
  locked: false
  confirmed_at: "2024-01-01 00:00:00"
  organisation: csiro

editor_user:
  email: "editor@example.com"
  encrypted_password: "$2a$10$qtbdzaGgpA2uZTngMjo1eudRHECv33iprWF7NWWL.gTMQ.V4/q3ey"
  first_name: "Editor"
  last_name: "User"
  role: "editor"
  locked: false
  confirmed_at: "2024-01-01 00:00:00"

regular_user:
  email: "regular@example.com"
  encrypted_password: "$2a$10$qtbdzaGgpA2uZTngMjo1eudRHECv33iprWF7NWWL.gTMQ.V4/q3ey"
  first_name: "Regular"
  last_name: "User"
  role: "member"
  locked: false
  confirmed_at: "2024-01-01 00:00:00"

locked_user:
  email: "locked@example.com"
  encrypted_password: "$2a$10$qtbdzaGgpA2uZTngMjo1eudRHECv33iprWF7NWWL.gTMQ.V4/q3ey"
  first_name: "Locked"
  last_name: "User"
  role: "member"
  locked: true
  confirmed_at: "2024-01-01 00:00:00"
```

- [ ] **Step 2: Update role tests**

In `test/models/user_test.rb`, replace the three `editor_or_admin?` tests (lines 34-44):

```ruby
  test "editor_or_admin? true for admin" do
    assert users(:admin_user).editor_or_admin?
  end

  test "editor_or_admin? true for editor" do
    assert users(:editor_user).editor_or_admin?
  end

  test "editor_or_admin? false for regular user" do
    assert_not users(:regular_user).editor_or_admin?
  end
```

with:

```ruby
  test "admin? true for admin" do
    assert users(:admin_user).admin?
  end

  test "admin? false for editor" do
    assert_not users(:editor_user).admin?
  end

  test "admin? false for regular user" do
    assert_not users(:regular_user).admin?
  end

  test "editor? true for admin (admin inherits editor)" do
    assert users(:admin_user).editor?
  end

  test "editor? true for editor" do
    assert users(:editor_user).editor?
  end

  test "editor? false for regular user" do
    assert_not users(:regular_user).editor?
  end

  test "editor_or_admin? delegates to editor?" do
    assert users(:admin_user).editor_or_admin?
    assert users(:editor_user).editor_or_admin?
    assert_not users(:regular_user).editor_or_admin?
  end

  test "role defaults to member" do
    user = User.new
    assert_equal "member", user.role
  end
```

- [ ] **Step 3: Run full test suite**

```bash
rails test
```

Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
jj describe -m "Update fixtures and tests for role column" && jj new
```

---

### Task 7: Update schema annotation and final cleanup

- [ ] **Step 1: Regenerate annotations**

```bash
rails annotate
```

- [ ] **Step 2: Run full test suite**

```bash
rails test
```

Expected: All 162+ tests pass.

- [ ] **Step 3: Commit**

```bash
jj describe -m "Regenerate model annotations for role column" && jj new
```

- [ ] **Step 4: Set bookmark**

```bash
jj bookmark set ryan/user-roles
```

---

## Manual Test Plan

- [ ] **Admin user management** — `/admin/users`: role badges show correctly, role dropdown works on edit page
- [ ] **Admin cannot demote self** — edit own profile: role dropdown should be hidden
- [ ] **Role changes persist** — change a user from Member to Editor, verify they can access editor features
- [ ] **Admin access** — only admin role users can access `/admin/db` and admin dashboard
- [ ] **Editor access** — editor role users can edit publications but not access admin dashboard
- [ ] **Member access** — regular members cannot edit publications or access admin
- [ ] **Locked users** — locked badge shown alongside role badge, locked users redirected on sign-in
- [ ] **Devise profile** — admin sees role dropdown on profile edit, non-admin does not
