class SetPublicationTypeToScientific < ActiveRecord::Migration[4.2]
  def change
  	Publication.update_all("publication_type = 'scientific'")
  end
end
