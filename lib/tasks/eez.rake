namespace :eez do
  desc "Seed EEZ table from CSV"
  task seed: :environment do
    require 'csv'
    csv_path = Rails.root.join('db/seeds/eezs.csv')
    abort "EEZ seed CSV not found at #{csv_path}" unless File.exist?(csv_path)

    count = 0
    CSV.foreach(csv_path, headers: true) do |row|
      Eez.find_or_create_by!(mrgid: row['mrgid'].to_i) do |eez|
        eez.geoname = row['geoname']
        eez.sovereign = row['sovereign']
        eez.territory = row['territory']
        count += 1
      end
    end
    puts "Seeded #{count} new EEZ records (#{Eez.count} total)"
  end

  desc "Link existing locations to EEZs using mapping CSV"
  task link_locations: :environment do
    require 'csv'
    csv_path = Rails.root.join('docs/database/mesophotic_org_EEZ_16112023.csv')
    abort "Location mapping CSV not found at #{csv_path}" unless File.exist?(csv_path)

    # Name mappings from the project's mapping CSV to VLIZ sovereign/territory names
    sovereign_aliases = {
      "USA" => "United States",
      "Comores" => "Comoros",
      "South Korea" => "Republic of Korea",
      "High Seas" => nil
    }

    # Map from mapping CSV territory to VLIZ territory (or :sovereign to use sovereign's main EEZ)
    territory_map = {
      # Australia sub-regions → main Australian EEZ
      ["Australia", "Coral Sea"] => ["Australia", "Australia"],
      ["Australia", "Great Barrier Reef"] => ["Australia", "Australia"],
      ["Australia", "Northern Australia"] => ["Australia", "Australia"],
      ["Australia", "Southeastern Australia"] => ["Australia", "Australia"],
      ["Australia", "Scott Reef"] => ["Australia", "Australia"],
      ["Australia", "Western Australia"] => ["Australia", "Australia"],
      # Brazil sub-regions
      ["Brazil", "Eastern Brazil"] => ["Brazil", "Brazil"],
      ["Brazil", "Fernando Noronha"] => ["Brazil", "Brazil"],
      ["Brazil", "St Peter and St Paul Archipelago"] => ["Brazil", "Brazil"],
      ["Brazil", "Trindade and Martin Vaz"] => ["Brazil", "Trindade"],
      # USA territories
      ["USA", "American Samoa"] => ["United States", "American Samoa"],
      ["USA", "Guam"] => ["United States", "Guam"],
      ["USA", "Gulf of Mexico"] => ["United States", "United States"],
      ["USA", "Hawaii"] => ["United States", "Hawaii"],
      ["USA", "Johnston Atoll"] => ["United States", "Johnston Atoll"],
      ["USA", "Mariana Islands"] => ["United States", "Northern Mariana Islands"],
      ["USA", "Puerto Rico"] => ["United States", "Puerto Rico"],
      ["USA", "Pulley Ridge"] => ["United States", "United States"],
      ["USA", "US Virgin Islands"] => ["United States", "United States Virgin Islands"],
      ["USA", "USA"] => ["United States", "United States"],
      # UK territories
      ["United Kingdom", "England"] => ["United Kingdom", "United Kingdom"],
      ["United Kingdom", "Scotland"] => ["United Kingdom", "United Kingdom"],
      ["United Kingdom", "Pitcairn Islands"] => ["United Kingdom", "Pitcairn"],
      ["United Kingdom", "Turks and Caicos"] => ["United Kingdom", "Turks and Caicos Islands"],
      # France territories
      ["France", "La Perouse"] => ["France", "Réunion"],
      ["France", "Reunion Islands"] => ["France", "Réunion"],
      # India sub-regions
      ["India", "Andaman and Nicobar Islands"] => ["India", "Andaman and Nicobar"],
      ["India", "Bay of Bengal"] => ["India", "India"],
      ["India", "Laccadive Sea"] => ["India", "India"],
      # Japan sub-regions
      ["Japan", "Ogasawara Islands"] => ["Japan", "Japan"],
      ["Japan", "Ryukyu Islands"] => ["Japan", "Japan"],
      # Mexico sub-regions
      ["Mexico", "Baja California"] => ["Mexico", "Mexico"],
      ["Mexico", "Gulf of Mexico"] => ["Mexico", "Mexico"],
      # Micronesia
      ["Micronesia", "Caroline Islands"] => ["Micronesia", "Micronesia"],
      ["Micronesia", "Chuuk atoll"] => ["Micronesia", "Micronesia"],
      # Other specific mappings
      ["Chile", "Salas y Gomez Nazca Ridge"] => ["Chile", "Chile"],
      ["Comores", "Comoros"] => ["Comores", "Comores"],
      ["Ecuador", "Galapagos Islands"] => ["Ecuador", "Galapagos"],
      ["Honduras", "Bay Islands"] => ["Honduras", "Honduras"],
      ["Kiribati", "Kiribati"] => ["Kiribati", "Gilbert Islands"],
      ["Mauritius", "Chagos Archipelago"] => ["Republic of Mauritius", "Chagos Archipelago"],
      ["Mauritius", "Mauritius"] => ["Republic of Mauritius", "Republic of Mauritius"],
      ["Netherlands", "Curacao"] => ["Netherlands", "Curaçao"],
      ["Netherlands", "Saba Bank"] => ["Netherlands", "Bonaire"],
      ["Saint Vincent and the Grenadines", "St Vincent"] => ["Saint Vincent and the Grenadines", "Saint Vincent and the Grenadines"],
      ["South Korea", "Jejudo Island"] => ["South Korea", "South Korea"],
      ["High Seas", "Saya de Malha Bank"] => nil
    }

    matched = 0
    unmatched = []
    CSV.foreach(csv_path, headers: true) do |row|
      location = Location.find_by(description: row['Description'])
      next unless location

      sovereign = row['SOVEREIGN1']&.strip
      territory = row['TERRITORY1']&.strip

      # Apply territory mapping first (most specific)
      if territory_map.key?([sovereign, territory])
        mapping = territory_map[[sovereign, territory]]
        if mapping.nil?
          next # Skip unmappable entries (e.g., High Seas)
        end
        sovereign, territory = mapping
      else
        # Apply sovereign alias
        sovereign = sovereign_aliases.fetch(sovereign, sovereign)
        next if sovereign.nil? # Skip entries with no sovereign mapping
      end

      eez = Eez.find_by(sovereign: sovereign, territory: territory)

      if eez
        location.update!(eez: eez)
        matched += 1
      else
        unmatched << "#{location.description} -> #{sovereign} / #{territory}"
      end
    end
    puts "Linked #{matched} locations to EEZs"
    if unmatched.any?
      puts "Unmatched (#{unmatched.count}):"
      unmatched.each { |u| puts "  #{u}" }
    end
  end
end
