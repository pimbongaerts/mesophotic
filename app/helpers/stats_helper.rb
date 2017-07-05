module StatsHelper
  def format_for_chart(category_model, category_model_ordered)
    # Create hash with category descriptions and counts
    category_model_counts = category_model.map{ |c| [c.description, c.publications_count] }.to_h
    # Total count across all categories
    total_count = category_model_counts.values.inject(:+)
    # Create list of ordered categories (that should be included)
    categories = category_model_ordered.map(&:description)
    # Create list of occurrences
    occurrences = []
    categories.each do |category|
      occurrences << category_model_counts[category]
    end
    # Add "other" category
    total_count_of_included_categories = occurrences.inject(:+)
    categories << "other"
    occurrences << (total_count - total_count_of_included_categories)
    
    [categories, occurrences]
  end

  def format_for_pie_chart(category_model, category_model_ordered)
    # Create hash with category descriptions and counts
    category_model_counts = category_model.map{ |c| [c.description, c.publications_count] }.to_h
    # Total count across all categories
    total_count = category_model_counts.values.inject(:+)
    # Create list of ordered categories (that should be included)
    categories = category_model_ordered.map(&:description)
    # Create list of occurrences
    categories_occurrences = {}
    categories.each do |category|
      if category_model_counts[category].nil?
        categories_occurrences[category] = 0
      else
        categories_occurrences[category] = category_model_counts[category]
      end
    end
    # Add "other" category
    total_count_of_included_categories = categories_occurrences.values.inject(:+)
    categories_occurrences["other"] = (total_count - total_count_of_included_categories)
    
    categories_occurrences.to_a
  end

  def format_for_time_search_chart(found_counts, total_counts)
    year_range = (2000..2016)
    categories = []
    found_occurrences = []
    not_found_occurrences = []

    year_range.each do |year|
      categories << year.to_s
      # Number of publications for which search term was found
      found_counts_year = found_counts.find_by_publication_year(year)
      if found_counts_year
        found_occurrence = found_counts_year.publications_count
      else
        found_occurrence = 0
      end
      found_occurrences << found_occurrence
      # Number of publications for which search term was not found
      total_counts_year = total_counts.find_by_publication_year(year)
      if total_counts_year
        total_occurrence = total_counts_year.publications_count
      else
        total_occurrence = 0
      end
      not_found_occurrences << total_occurrence - found_occurrence
    end
    return categories, found_occurrences, not_found_occurrences
  end

  # Publications over depth
  def get_depth_range_data(publications)
    require 'histogram/array'  
    depths = []
    # Obtain min and max depth for each publication and transform into range
    publications.each do |publication|
      if publication.min_depth and publication.max_depth
        # Trim min and max depths to 30-200 m
        if publication.min_depth < 30
          min_depth = 30
        else
          min_depth = publication.min_depth
        end
        if publication.max_depth > 150
          max_depth = 150
        else
          max_depth = publication.max_depth
        end
        # Transform to ranges
        depths.push(*(min_depth..max_depth))
      end
    end
    # Define depth bins for histogram
    depth_bins = (30..150).step(1).map(&:to_i)
    categories, occurrences = depths.histogram(depth_bins, 
                                               :bin_boundary => :avg)
    return categories, occurrences
  end

  # Platform use over depth
  def get_platform_use_over_depth(platforms, publications)
    require 'histogram/array'  
    # Initialize series for raw data and histogram
    raw_platform_depths = {}
    histo_occurrences = {}
    platforms.each do |platform|
      raw_platform_depths[platform.description] = []
      histo_occurrences[platform.description] = []
    end
    raw_platform_depths["other"] = []
    histo_occurrences["other"] = []
    # Obtain min and max depth for each publication and transform into range
    publications.each do |publication|
      if publication.min_depth and publication.max_depth
        # Trim min and max depths to 30-200 m
        publication.min_depth < 30 ? min_depth = 30 : min_depth = publication.min_depth
        publication.max_depth > 150 ? max_depth = 150 : max_depth = publication.max_depth
        # Transform to ranges and add to each linked platform for that publication
        publication.platforms.each do |platform|
          if raw_platform_depths.key?(platform.description)
            raw_platform_depths[platform.description].push(*(min_depth..max_depth))
          else
            raw_platform_depths["other"].push(*(min_depth..max_depth))
          end
        end
      end
    end
    # Define depth bins for histogram
    depth_bins = (30..150).step(1).map(&:to_i)
    categories = []
    raw_platform_depths.keys.each do |platform|
      categories, histo_occurrences[platform] = raw_platform_depths[platform].histogram(depth_bins, 
                                                                            :bin_boundary => :avg)
    end
    return categories, histo_occurrences
  end

  # Focusgroup use over depth
  def get_focusgroup_over_depth(focusgroups, publications)
    require 'histogram/array'  
    # Initialize series for raw data and histogram
    raw_focusgroup_depths = {}
    histo_occurrences = {}
    focusgroups.each do |focusgroup|
      raw_focusgroup_depths[focusgroup.description] = []
      histo_occurrences[focusgroup.description] = []
    end
    raw_focusgroup_depths["other"] = []
    histo_occurrences["other"] = []
    # Obtain min and max depth for each publication and transform into range
    publications.each do |publication|
      if publication.min_depth and publication.max_depth
        # Trim min and max depths to 30-200 m
        publication.min_depth < 30 ? min_depth = 30 : min_depth = publication.min_depth
        publication.max_depth > 150 ? max_depth = 150 : max_depth = publication.max_depth
        # Transform to ranges and add to each linked focusgroup for that publication
        publication.focusgroups.each do |focusgroup|
          if raw_focusgroup_depths.key?(focusgroup.description)
            raw_focusgroup_depths[focusgroup.description].push(*(min_depth..max_depth))
          else
            raw_focusgroup_depths["other"].push(*(min_depth..max_depth))
          end
        end
      end
    end
    # Define depth bins for histogram
    depth_bins = (30..150).step(1).map(&:to_i)
    categories = []
    raw_focusgroup_depths.keys.each do |focusgroup|
      categories, histo_occurrences[focusgroup] = raw_focusgroup_depths[focusgroup].histogram(depth_bins, 
                                                                            :bin_boundary => :avg)
    end
    return categories, histo_occurrences
  end

end