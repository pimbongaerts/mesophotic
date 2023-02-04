require 'net/http'
require 'net/https'

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

  def word_association
    [Platform, Field, Focusgroup, Location].reduce({}) { |r, model|
      r.merge model.model_name.plural => model.all.reduce({}) { |r, m|
        words = m.short_description.split(';').map(&:strip) rescue []
        r.merge words.reduce({}) { |r, w|
          r.merge w.downcase => m.id
        }
      }
    }
  end

  def species_association
    Species.all.reduce([]) { |r, s|
      words = s.short_description.split(';').map(&:strip) rescue []
      r << words.reduce({}) { |r, w|
        r.merge w.downcase => s.id
      }
    }
  end

  def linkify content
    word_association.each { |m, ws|
      ws.each { |w, id|
        content = content.gsub(/\b(#{w}[\w]*|#{w.pluralize})\b/i) { |match|
          link_to (raw $1), summary_path(m, id)
        }
      }
    }

    species_association.each { |s|
      original = content
      content = content.gsub(/\b(#{s.keys.first}[\w]*)\b/i) { |match|
        link_to (raw "<em>#{$1}</em>"), summary_path('species', s.values.first)
      }

      if original != content
        content = content.gsub(/\b(#{s.keys.last}[\w]*)\b/i) { |match|
          link_to (raw "<em>#{$1}</em>"), summary_path('species', s.values.last)
        }
      end
    }

    raw content
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
  def count_publications_over_time(publications)
    annual_counts = publications.annual_counts
    last_year = Time.new.year - 1
    year_range = (1970..last_year)
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
  	last_year = Time.new.year - 1
    year_range = (1990..last_year)
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
        data << {name: country.iso_short_name, lat: country.geo["latitude"],
                 lon: country.geo["longitude"], z: freqs }
      end
    end
    data
  end

  # Counts the number of occurrences for each location in the photo model
  # and outputs corresponding coordinates
  def count_geographic_occurrences_of_photos(locations)
    data = []
    locations.each do |location|
      data << {
        name: location.description,
        lat: location.latitude,
        lon: location.longitude,
        z: location.photos.count,
        ownURL: location_path(location)
      }
    end
    data
  end

  # Counts the number of occurrences for each location
  def count_geographic_occurrences_of_publications(publications)
    freqs = Hash.new(0)

    # Count occurrences
    publications.each do |publication|
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

  # Counts the number of occurrences for each location for a particular user
  def count_geographic_occurrences_of_publications_from_user(user)
    count_geographic_occurrences_of_publications(user.publications)
  end
end

class String
  def numeric?
    Float(self) != nil rescue false
  end
end
