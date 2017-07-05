module PhotosHelper
  # Summary of photos database
  def photo_stats(photos)
  	categories = []
  	occurrences = []

    categories << "Surface"
    occurrences << photos.where(underwater: false).count

    categories << "Underwater"
    occurrences << photos.where(underwater: true).count

    categories << "Containing species"
    occurrences << photos.where(contains_species: true).count

	[categories, occurrences]
	end

  # Obtain site or location coordinates for photo
  def format_photo_for_world_map(photo)
    data = []
    if photo.location
      data << {name: photo.location.description, lat: photo.location.latitude, 
               lon: photo.location.longitude, z: 1, 
               ownURL: location_path(photo.location) }
    elsif photo.site
      data << {name: "#{photo.site.description} (#{photo.site.location.description})", 
               lat: photo.site.latitude, 
               lon: photo.site.longitude, z: 1,
               ownURL: site_path(photo.site) }
    end
  end

end
