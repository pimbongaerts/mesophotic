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
end
