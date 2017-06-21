module PublicationsHelper
  # Counts the number of occurrences for each value of a particular category 
  # (e.g. location, platform) in the publication model
  def count_category_in_publications(category_model)
    categories = []
    occurrences = []
    category_model.each do |category|
      categories << category.description
      occurrences << category.publications.count
    end
    [categories, occurrences]
  end

  # Counts the number of occurrences for each location in the publication model 
  # and outputs corresponding coordinates
  def format_sites_and_coordinates(sites)
    data = []
    sites.each do |site|
      data << {name: "#{site.site_name} (#{site.location.description})", 
               lat: site.latitude, 
               lon: site.longitude, z: 1 }
    end
    data
  end
  
  # Obtain search result snippet for a particular publication
  def obtain_snippet(contents, search_term)
    # Find first occurrence of search term
    first_occurrence_index = contents.index(search_term)
    length_of_contents = contents.length
    # Determine beginning position of snippet
    if first_occurrence_index
      if first_occurrence_index < 300
        snippet_start = 0
      else
        snippet_start = first_occurrence_index - 300
      end
      # Extract snippet
      snippet =  contents.force_encoding("UTF-8")[snippet_start,600].squish.
                          gsub! search_term, "<b>#{search_term}</b>"
     simple_format "... #{snippet}..."
    else
      "Search term not found!"
    end
  end

  # Count occurrence of word in contents
  def count_word_in_contents(word, contents)
    word_count = contents.scan(/\b#{word}\b/i).count
    if word_count > 0
      word_count
    else 
      ""
    end
  end

  # Return a randomly selected "featured" publication
  def get_featured_publication(publications)
    offset = rand(publications.count)
    publications.offset(offset).first
  end

  # Compile a variable with contents of all publications
  def overall_publication_contents(publications)
    contents = []
    publications.each do |publication|
      if publication.contents?
        contents << publication.contents.force_encoding("UTF-8")
      end
    end
    return contents.join(" ")
  end
  
  def format_authors(publication)
    # Authors of publication (string)
    authors = publication.authors
    author_list = authors.split(",")
    authors_formatted = []
    # Users associated with publication (usually subset of authors)
    users = publication.users
    # Iterate over authors
    author_list.each do |author|
      # Assess whether one of the users represents this author
      found_user = false
      users.each do |user|
        # If last name matches
        if author.include? user.last_name
          user_initial = user.first_name[0] # TODO: CHANGE ONCE ADDED TO MODEL
          # Check if only occurrence of this last name in list of authors
          author_occurrence = authors.scan(/(?=#{user.last_name})/).count
          if author_occurrence >= 1
            # Check initials if multiple occurrence
            initials = author.split()[1]
            if initials[0] == user_initial # TODO: CHANGE ONCE ADDED TO MODEL
              author_formatted = link_to author, member_path(user.id)
              authors_formatted << author_formatted
              found_user = true
            end
          end
        end
      end
      # If none of the users represent the author then output unformatted
      if not found_user
        authors_formatted << author
      end
    end
    return authors_formatted.join(", ").html_safe
  end

  # Return formatted Publication
  def format_publication_citation(publication)
    publication_title = link_to truncate(publication.title, length: 150),
                                publication
    formatted_authors = format_authors(publication)
    citation = "<strong>#{publication_title}</strong>" \
               "<strong> | #{publication.publication_format}</strong><br>" \
               "#{formatted_authors} " \
               "(#{publication.publication_year})<br>"
    if publication.scientific_article?
      publication_journal = publication.journal.name if publication.journal
      citation << "<em>#{publication_journal}</em> "
      if !publication.pages.blank? && !publication.volume.blank?
        citation << "#{publication.volume}:#{publication.pages} "
      end
    elsif publication.chapter?
      citation << "in: <em>#{publication.book_title}</em>" \
                  " (#{publication.book_publisher})" \
                  " by #{publication.book_authors}"
    else
      citation << "<em>#{publication.book_publisher}</em> "
    end
    return citation
  end
end