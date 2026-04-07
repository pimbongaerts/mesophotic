class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # Foreign keys used in joins and includes
    add_index :publications, :journal_id
    add_index :publications, :contributor_id

    # Columns used in WHERE clauses (statistics, base_search scopes)
    add_index :publications, :publication_year
    add_index :publications, :publication_type
    add_index :publications, :publication_format

    # Used in MAX(updated_at) cache keys on every page view
    add_index :publications, :updated_at

    # Validations: user_id used in expired scope
    add_index :validations, :user_id
  end
end
