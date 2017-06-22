module StatsHelper
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