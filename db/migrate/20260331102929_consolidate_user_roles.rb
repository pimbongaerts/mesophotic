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
