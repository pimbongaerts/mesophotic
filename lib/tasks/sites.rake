namespace :sites do
  desc "Fix sites with 0,0 coordinates and assign missing locations"
  task fix_coordinates: :environment do
    coordinate_fixes = {
      "Tsitsikamma National Park" => { latitude: -33.988, longitude: 23.846 },
      "Eilat"                     => { latitude: 29.558, longitude: 34.948 },
      "American Shoal"            => { latitude: 24.522, longitude: -81.518 },
      "Ant Atoll"                 => { latitude: 6.776, longitude: 157.961 },
      "Flower Garden Banks National Marine Sanctuary" => { latitude: 27.900, longitude: -93.600 },
      "Carrie Bow Cay"            => { latitude: 16.803, longitude: -88.082 },
      "Florida Straits"           => { latitude: 24.060, longitude: -81.100 },
      "San Andres"                => { latitude: 12.500, longitude: -81.700 },
      "Cartagena"                 => { latitude: 10.270, longitude: -75.600 },
      "Ningaloo"                  => { latitude: -21.873, longitude: 113.974 },
      "Cozumel"                   => { latitude: 20.423, longitude: -86.922 },
      "João Pessoa"               => { latitude: -7.120, longitude: -34.845 },
      "Gotland"                   => { latitude: 57.845, longitude: 18.567 },
      "Rottnest Island"           => { latitude: -32.006, longitude: 115.507 },
    }

    # Map site names to location descriptions for orphaned sites
    location_fixes = {
      "Ant Atoll"                 => "Micronesia - Caroline Islands (Pohnpei)",
      "Flower Garden Banks National Marine Sanctuary" => "USA - Gulf of Mexico",
      "Carrie Bow Cay"            => "Belize",
      "Florida Straits"           => "USA - Continental Atlantic Ocean",
      "San Andres"                => "Colombia - Caribbean Sea",
      "Cartagena"                 => "Colombia - Caribbean Sea",
      "Ningaloo"                  => "Australia - Western Australia",
      "Cozumel"                   => "Mexico - Caribbean Sea",
      "João Pessoa"               => "Brazil - Eastern Brazil",
      "Gotland"                   => "Sweden",
      "Rottnest Island"           => "Australia - Western Australia",
    }

    # Fix coordinates
    fixed_coords = 0
    Site.where(latitude: 0.0, longitude: 0.0).find_each do |site|
      if coordinate_fixes.key?(site.site_name)
        coords = coordinate_fixes[site.site_name]
        site.update_columns(latitude: coords[:latitude], longitude: coords[:longitude])
        puts "Coords: #{site.site_name} -> #{coords[:latitude]}, #{coords[:longitude]}"
        fixed_coords += 1
      else
        puts "Skipped: #{site.site_name} (unknown coordinates, left at 0,0)"
      end
    end

    # Fix missing locations
    fixed_locs = 0
    Site.where(location_id: nil).find_each do |site|
      if location_fixes.key?(site.site_name)
        location = Location.find_by(description: location_fixes[site.site_name])
        if location
          site.update_columns(location_id: location.id)
          puts "Location: #{site.site_name} -> #{location.description}"
          fixed_locs += 1
        else
          puts "Location not found: #{location_fixes[site.site_name]} for #{site.site_name}"
        end
      else
        puts "Skipped: #{site.site_name} (no location mapping)"
      end
    end

    puts "Fixed #{fixed_coords} coordinates, #{fixed_locs} locations"
  end
end
