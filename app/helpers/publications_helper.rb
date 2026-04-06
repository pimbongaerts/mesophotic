module PublicationsHelper
  # Obtain search result snippet for a particular publication
  def obtain_snippet(contents, search_term)
    return "…" if contents.blank?

    start = [0, contents.downcase.index(search_term.downcase) || 0 - 300].max
    snippet = ERB::Util.html_escape(contents[start, 400].squish)
    highlighted = snippet.gsub(/(#{Regexp.escape(search_term)})/i, '<strong>\1</strong>')
    "…#{highlighted}…".html_safe
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
      # If none of the users represent the author then output escaped
      if not found_user
        authors_formatted << ERB::Util.html_escape(author)
      end
    end
    return safe_join(authors_formatted, ", ")
  end

  # Return formatted Publication
  def format_publication_citation(publication)
    h = method(:sanitize_and_escape)
    publication_title = link_to truncate(publication.title, length: 150),
                                publication
    formatted_authors = format_authors(publication)
    parts = []
    parts << content_tag(:strong, publication_title)
    parts << content_tag(:strong, " | #{h.(publication.publication_format)}")
    parts << tag.br
    parts << formatted_authors
    parts << " (#{h.(publication.publication_year)})"
    parts << tag.br
    if publication.scientific_article?
      parts << content_tag(:em, h.(publication.journal&.name)) << " "
      if publication.pages.present? && publication.volume.present?
        parts << "#{h.(publication.volume)}:#{h.(publication.pages)} "
      end
    elsif publication.chapter?
      parts << "in: " << content_tag(:em, h.(publication.book_title))
      parts << " (#{h.(publication.book_publisher)})"
      parts << " by #{h.(publication.book_authors)}"
    else
      parts << content_tag(:em, h.(publication.book_publisher)) << " "
    end
    safe_join(parts)
  end

  private

  def sanitize_and_escape(value)
    ERB::Util.html_escape(value.to_s)
  end

  def search_param title, options, param_name, params, scrollable=false
    parts = []
    parts << content_tag(:h5, title) if title.present?
    list_items = options.map do |option|
      identifier = "search_params[#{param_name}][#{option}]"
      checked = params[:search_params][param_name].try(:include?, option)
      label_text = option.length > 3 ? option.titleize : option.upcase
      content_tag(:li) do
        label_tag(identifier) do
          check_box_tag(identifier, option, checked, id: identifier, class: "form-check-input") +
          " #{label_text}"
        end
      end
    end
    parts << content_tag(:ul, safe_join(list_items), class: (scrollable ? "scrollable" : nil))
    safe_join(parts)
  end
end
