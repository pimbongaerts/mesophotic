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

    matched = 0
    unmatched = []
    CSV.foreach(csv_path, headers: true) do |row|
      location = Location.find_by(description: row['Description'])
      next unless location

      sovereign = row['SOVEREIGN1']&.strip
      territory = row['TERRITORY1']&.strip
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
