namespace :db do
	#NOTE: first run rake db:migrate until first error
  #NOTE: Then comment out validations in Publications and run import_db
  desc "Import database from previous release"
  	task :import_db => :environment do     # Step 1
      convert_contents_field_to_utf8
  	end
    task :import_pdfs => :environment do  # Step 2
      import_pdfs
    end
    task :import_word_exclusion => :environment do  # Step 2
      import_word_exclusion
    end
    task :import_sites => :environment do  # Step 2
      import_sites
    end
    task :import_species => :environment do
      import_species
    end
    task :import_emails => :environment do
      import_emails
    end
    # TEMPORARY
    task :test_db => :environment do
      test_db
    end
end

# Import existing PDFs as Paperclip attachments
def convert_contents_field_to_utf8
  # NOTE: comment out all validations of new fields in Publication model
  Publication.all.each do |publication|
    if not publication.contents.nil?
      new_contents = publication.contents.force_encoding("UTF-8").encode("UTF-8")
      #TODO: MAYBE INCLUDE STANDARD COMMAS ETC
      new_contents.gsub!(/[^0-9a-z ]/i, '')
      publication.ISSN = new_contents
      publication.contents = ""
      publication.publication_type = "article"
      publication.save!
    end
  end
  Publication.all.each do |publication|
    if not publication.contents.nil?
      publication.contents = publication.ISSN
      publication.ISSN = ""
      publication.save!
    end
  end
end

# Import existing PDFs as Paperclip attachments
def import_pdfs
  batch_counter = 0
  Publication.all.each do |publication|
    if batch_counter >= 10
      puts "sleep 5 min..."
      sleep(5.minutes)
      batch_counter = 0
    end

    if !publication.pdf.exists?
      batch_counter += 1
      puts publication.title
      filename = "#{Rails.root.to_s}/db/import/pdfs/#{publication.filename}.pdf"
      if File.exist?(filename)
        file = File.open(filename)
        publication.pdf = file
        file.close
        publication.save!
      else
        puts "***File not found: #{filename}"
      end
    end
  end
end

# Import words for the word_exclusion model
def import_word_exclusion
  WordExclusion.delete_all
  CSV.foreach("#{::Rails.root}/db/import/wordcloud.txt") do |row|
    unless row[0].nil?
      WordExclusion.find_or_create_by(word: row[0].strip)
    end
  end
end

# Import sites and link to publications
def import_sites
  Site.delete_all
  CSV.foreach("#{::Rails.root}/db/import/sites_utf8.csv") do |row|
    # Skip site if no coordinates are given
    if row[4].nil? || row[5].nil?
      puts "ERROR: Site without coordinates: #{row[0]}"
      next
    end

    # Use default name if no site_name is given
    if row[6].nil?
      site_name = "Unnamed site"
    else
      site_name = row[6].force_encoding("UTF-8").encode("UTF-8")
    end

    latitude = row[4].to_d
    longitude = row[5].to_d

    # Check if other sites exist with the same name
    sites_with_same_name = Site.where(site_name: site_name)
    if sites_with_same_name.count > 0
      # Check what the nearest distance is of all the sites
      min_distance = -1
      sites_with_same_name.each do | site_with_same_name |
        distance = get_distance([site_with_same_name.latitude, 
                                 site_with_same_name.longitude], 
                                [latitude, longitude])
        if distance < min_distance || min_distance == -1
          min_distance = distance
          @nearest_site = Site.find_by_id(site_with_same_name.id)
        end
      end
      # Merge site with nearest site (with same name) that is within 1km
      if min_distance == 0
        @site = @nearest_site
      elsif min_distance <= 1000.0
        @site = @nearest_site
        @site.estimated = true
        puts "MERGED: Site for #{row[0]} merged: #{@site.site_name} - " \
             "distance: #{min_distance}"
      # Alternatively create new site with same name
      else
        if site_name != "Unnamed site"
          puts "DUPLICATE NAME: #{site_name} - distance: #{min_distance} m " \
               "(nearest: #{@nearest_site.latitude} " \
               "#{@nearest_site.longitude}" \
               ", new: #{latitude} #{longitude})"
        end
        @site = Site.new(site_name: site_name,
                         latitude: latitude,
                         longitude: longitude)
      end
    else
      @site = Site.new(site_name: site_name,
                       latitude: latitude,
                       longitude: longitude)
    end

    # Estimated (convert to Boolean )
    if row[7] == "Estimated" || @site.estimated == true
      @site.estimated = true
    else
      @site.estimated = false
    end

    # Location (associated value)
    if row[1]
      location_description = row[1].strip
      @location = Location.find_by(description: location_description)
      if not @location.present?
        puts "ERROR: No location called #{location_description}"
        @site.location_id = -1
      else
        @site.location_id = @location.id  
      end
    end
    @site.save!
    
    # Link to publication (associated value)
    if row[0]
      @publication = Publication.find_by(filename: row[0].strip)
      if @publication
        @publication.sites << @site
        @publication.save!
      else
        puts "ERROR: Publication #{row[0]} for site: #{row[6]} not found!"
      end
    else
      puts "ERROR: Publication not given for site: #{row[6]}!"
    end
  end
end

# TODO: TEMPORARY TEST FUNCTION
def test_db
  Publication.all.each do |publication|
    unless publication.article_title.nil?
      puts publication.article_title.encoding
    end
  end
end

# Import species data from excel sheet
def import_species
  #Species.delete_all
  CSV.foreach("#{::Rails.root}/db/species_import.csv") do |row|
      @focusgroup = Focusgroup.find_by_description(row[1])
      
      if not @focusgroup.present?
        puts "ERROR: No focusgroup called #{row[1]}"
        break
      end

      if row[4].nil?
        aims_webid = nil
      else
        aims_webid = row[4].to_s.rjust(4, "0")
      end

      @species = Species.new(name: row[0],
                             focusgroup_id: @focusgroup.id,
                             #region: ignore row[2],
                             fishbase_webid: row[3],
                             aims_webid: aims_webid,
                             coraltraits_webid: row[5])
      @species.save!
  end
end

def import_emails
  # Update all emails
  CSV.foreach("#{::Rails.root}/emails.txt") do |row|
    @user = User.find_by_last_name(row[0])
    if @user
      puts row[1].strip
      @user.email = row[1].strip
      @user.skip_reconfirmation!
      @user.save!
    else
      puts "ERROR: No user with last name #{row[0]}"
    end
  end
  # List all emails that are still ending in @mesophotic.org
  puts "Following users still have email ending in @mesophotic.org:"
  User.find_each do |user|
    if user.email.strip.last(15) == "@mesophotic.org"
      puts "#{user.last_name},#{user.email}"
    end
  end
end

private

# Calculates distance between decimal degrees coordinates
# from http://stackoverflow.com/a/12969617/7853850
def get_distance(loc1, loc2)
  rad_per_deg = Math::PI/180  # PI / 180
  rkm = 6371                  # Earth radius in kilometers
  rm = rkm * 1000             # Radius in meters

  dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
  dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

  lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
  lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

  a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
  c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

  rm * c # Delta in meters
end