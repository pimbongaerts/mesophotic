module ApplicationHelper
  # Page title
  def title(value)
    unless value.nil?
      @title = "#{value} | Mesophotic.org"
    end
  end

  def new_table_row_on_iteration(i, iteration)
    if i/iteration.to_f == i/iteration.to_i && i > 0
      "</tr><tr>".html_safe
    end
  end

def url_exists?(url_string)
  url = URI.parse(url_string)
  req = Net::HTTP.new(url.host, url.port)
  res = req.request_head(url.path)
  res.code != "404" && res.code != "500" # false if returns 404 or 500
rescue Errno::ENOENT
  false # false if can't find the server
end

  # Count frequency of words and return most frequent (cut_off)
  def word_count(value, cut_off)
      exclusion_list = WordExclusion.pluck(:word)
      words = value.force_encoding("UTF-8").split(/[^a-zA-Z]/)
      freqs = Hash.new(0)
      total_word_count = words.count

      words.each do |word|
        unless exclusion_list.include? word.downcase or word.length < 2
          freqs[word] += 1
        end
      end
      freqs = freqs.sort_by {|x,y| y }
      freqs.reverse!
      conv_factor = Publication::WORDCLOUD_FREQLIMIT.to_f / freqs.first[1]
      word_list = "["
      counter = 0
      freqs.each do |word, freq|
        counter += 1
        break if counter > cut_off
        norm_freq = (freq * conv_factor).to_i
        word_list += "['#{word}', #{norm_freq}],"
      end
      word_list += ']'

      return word_list
  end

  # Determine a score for how relevant the publication is to deep reefs
  def mesophotic_score(value)
    word_count = value.scan(/\w+/).size
    deep_count = 0
    deep_count += value.downcase.scan(/mesophotic/).count
    deep_count += value.downcase.scan(/mce/).count
    deep_count += value.downcase.scan(/mcr/).count
    deep_count += value.downcase.scan(/deep reef/).count
    return deep_count, word_count
  end

  # Counts the number of total number of publications over time (years)
  def count_publications_over_time(annual_counts)
    year_range = (1970..2016)
    categories = []
    values = []
    updated_count = 0
    year_range.each do |year|
      categories << year.to_s
      if annual_counts.key?(year)
        updated_count += annual_counts[year]
        values << updated_count
      else
        values << updated_count
      end
    end
    return categories, values
  end

  # Counts the number of first authors of publications over time (years)
  def count_first_authors_over_time(publications)
    # Get a list of first authors for each year
    year_author_list = Hash.new(0)
    publications.each do |publication|
	    first_author = publication.authors.split()[0]
	    year_key = publication.publication_year.to_s
	    if not year_author_list.key?(year_key)
	      year_author_list[year_key] = []
	      year_author_list[year_key] <<  first_author
	    elsif not year_author_list[year_key].include? first_author
	      year_author_list[year_key] <<  first_author
	    end
  	end
  	# Count number of unique first authors for each year
  	year_range = (1990..2016)
  	categories = []
    values = []
  	year_range.each do |year|
  	  categories << year.to_s
  	  if year_author_list.key? year.to_s
  	    values << year_author_list[year.to_s].count
  	  else
        values << 0
  	  end
  	end
  	return categories, values
  end

  # Counts the number of occurrences for each location in the user model
  def count_geographic_occurrences_of_users(users)
    freqs = Hash.new(0)
    # Count occurrences
    users.each do |user|
      if user.organisation
        if user.organisation.country
          freqs[user.organisation.country] += 1
        end
      end
    end
    # Summarise with coordinates
    data = []
    freqs.each do |country_code, freqs|
      if ISO3166::Country[country_code]
        country = ISO3166::Country[country_code]
        data << {name: country.name, lat: country.latitude_dec,
                 lon: country.longitude_dec, z: freqs }
      end
    end
    data
  end


  # Counts the number of occurrences for each location in the publication model
  # and outputs corresponding coordinates
  def count_geographic_occurrences_of_publications(locations)
    data = []
    locations.each do |location|
      data << {name: location.description, lat: location.latitude,
               lon: location.longitude, z: location.publications.count,
               ownURL: location_path(location) }
    end
    data
  end

  # Counts the number of occurrences for each location in the photo model
  # and outputs corresponding coordinates
  def count_geographic_occurrences_of_photos(locations)
    data = []
    locations.each do |location|
      data << {name: location.description, lat: location.latitude,
               lon: location.longitude, z: location.photos.count,
               ownURL: location_path(location) }
    end
    data
  end

  # Counts the number of occurrences for each location for a particular user
  def count_geographic_occurrences_of_publications_from_user(user)
    freqs = Hash.new(0)
    # Count occurrences
    user.publications.each do |publication|
      publication.locations.each do |location|
        freqs[location] += 1
      end
    end
    # Summarise with coordinates
    data = []
    freqs.each do |location, freqs|
      data << {name: location.description, lat: location.latitude,
               lon: location.longitude, z: freqs }
    end
    data
  end

  # Counts the number of occurrences for each location in the publication model
  # and outputs corresponding coordinates
  def get_site_coordinates(sites)
    data = []
    sites.each do |site|
      data << {name: site.site_name, lat: site.latitude,
               lon: site.longitude, z: site.publications.count,
               ownURL: site_path(site) }
    end
    data
  end

end
