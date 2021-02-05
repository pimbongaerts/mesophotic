module PublicationsHelper
  # Obtain search result snippet for a particular publication
  def obtain_snippet(contents, search_term)
    return "…" if contents.blank?

    start = [0, contents.downcase.index(search_term.downcase) || 0 - 300].max
    snippet = contents.force_encoding("UTF-8")[start, 600]
                      .squish
                      .gsub(search_term, "<strong>#{search_term}</strong>")
    simple_format "…#{snippet}…"
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
    publications = publications.empty? ? Publication.all : publications
    offset = rand(publications.count)
    publications.offset(offset).first
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
            if initials && initials[0] == user_initial # TODO: CHANGE ONCE ADDED TO MODEL
              author_formatted = link_to author, member_pages_path(user.id)
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

  def search_param title, options, param_name, params, scrollable=false
    open_tag = scrollable ? "<ul class=\"scrollable\">" : "<ul>"
    return ("<h5>#{title}</h5>" + open_tag + options.map do |option|
      identifier = "search_params[#{param_name}[#{option}]]"
      "<li>" \
      "  <label for=\"#{identifier}\">" \
      "    <input type=\"checkbox\"" \
      "           name=\"#{identifier}\"" \
      "           id=\"#{identifier}\"" \
      "           #{params[:search_params][param_name].try(:include?, option) ? "checked=\"checked\"" : ""}>" \
      "    #{option.to_s.titleize}" \
      "  </label>" \
      "</li>"
    end.join + "</ul>").html_safe
  end
end
