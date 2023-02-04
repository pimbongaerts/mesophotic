namespace :sqlite do
  desc 'Migrate Boolean columns from t/f to 1/0'
  task migrate_boolean_columns: :environment do
    Journal.where("open_access = 't'").update_all("open_access = 1")
    Journal.where("open_access = 'f'").update_all("open_access = 0")

    Photo.where("contains_species = 't'").update_all("contains_species = 1")
    Photo.where("contains_species = 'f'").update_all("contains_species = 0")
    Photo.where("underwater = 't'").update_all("underwater = 1")
    Photo.where("underwater = 'f'").update_all("underwater = 0")
    Photo.where("creative_commons = 't'").update_all("creative_commons = 1")
    Photo.where("creative_commons = 'f'").update_all("creative_commons = 0")
    Photo.where("showcases_location = 't'").update_all("showcases_location = 1")
    Photo.where("showcases_location = 'f'").update_all("showcases_location = 0")
    Photo.where("media_gallery = 't'").update_all("media_gallery = 1")
    Photo.where("media_gallery = 'f'").update_all("media_gallery = 0")

    Post.where("draft = 't'").update_all("draft = 1")
    Post.where("draft = 'f'").update_all("draft = 0")

    Presentation.where("oral = 't'").update_all("oral = 1")
    Presentation.where("oral = 'f'").update_all("oral = 0")

    Publication.where("new_species = 't'").update_all("new_species = 1")
    Publication.where("new_species = 'f'").update_all("new_species = 0")
    Publication.where("original_data = 't'").update_all("original_data = 1")
    Publication.where("original_data = 'f'").update_all("original_data = 0")
    Publication.where("mesophotic = 't'").update_all("mesophotic = 1")
    Publication.where("mesophotic = 'f'").update_all("mesophotic = 0")
    Publication.where("mce = 't'").update_all("mce = 1")
    Publication.where("mce = 'f'").update_all("mce = 0")
    Publication.where("tme = 't'").update_all("tme = 1")
    Publication.where("tme = 'f'").update_all("tme = 0")

    Site.where("estimated = 't'").update_all("estimated = 1")
    Site.where("estimated = 'f'").update_all("estimated = 0")

    User.where("admin = 't'").update_all("admin = 1")
    User.where("admin = 'f'").update_all("admin = 0")
    User.where("locked = 't'").update_all("locked = 1")
    User.where("locked = 'f'").update_all("locked = 0")
    User.where("editor = 't'").update_all("editor = 1")
    User.where("editor = 'f'").update_all("editor = 0")
  end
end
