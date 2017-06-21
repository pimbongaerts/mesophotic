class SetPublicationTypeToScientific < ActiveRecord::Migration
  def change
  	Publication.update_all("publication_type = 'scientific'")
  end
end
