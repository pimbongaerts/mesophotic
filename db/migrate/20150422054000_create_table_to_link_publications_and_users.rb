class CreateTableToLinkPublicationsAndUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :publications_users, id: false do |t|
      t.belongs_to :publication, index: true
      t.belongs_to :user, index: true
    end
  end
end
