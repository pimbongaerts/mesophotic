require 'csv'

namespace :db do
  desc "Fill Locations table with data from CSV file"
   task :populate => :environment do
      #Rake::Task['db:reset'].invoke
      create_locations
   end
  desc "Fill Organisations table with data from CSV file"
   task :populate => :environment do
     #Rake::Task['db:reset'].invoke
     create_organisations
   end
  desc "Fill Publications table with data from CSV file"
   task :populate => :environment do
      #Rake::Task['db:reset'].invoke
      create_publications
    end
    desc "Fill Presentations table with data from CSV file"
     task :populate => :environment do
        #Rake::Task['db:reset'].invoke
        create_presentations
      end
  desc "Fill User table with data from CSV file"
   task :populate => :environment do
     #Rake::Task['db:reset'].invoke
     create_users
   end
  desc "Fill Sites table with data from CSV file"
   task :populate => :environment do
      #Rake::Task['db:reset'].invoke
      create_sites
    end
  desc "Reset passwords after adding this file to gitignore"
    task :reset_passwords => :environment do
      reset_passwords
    end
end

def create_organisations
  CSV.foreach("#{::Rails.root}/db/import/organisations.csv") do |row|
    # Skip first row
    next if row[0]=="original_id"
    # Initialize new user record with non-associated values (column 10-21 or K-V)
    @organisation = Organisation.new(
      :id => row[0],
      :name => row[1],
    )
    # Country
    new_country_convention = {1 => 'AU', 2 => 'US', 3 => 'US', 4 =>  'PR', 5 => 'PW', 
      6 => 'VI', 7 =>  'CW', 8 =>  'IL', 10 =>  'NL', 12 =>  'BM', 13 => 'IT',
      14 => 'JP', 15 => 'BR', 16 => 'BB', 17 => 'MX', 18 => 'TR', 19 => 'UK', 20 => 'TW'}
    @organisation.country = new_country_convention[row[2]]
    # Save record
    @organisation.save!
  end
end

def create_users
  CSV.foreach("#{::Rails.root}/db/import/people.csv") do |row|
    # Skip first row
    next if row[0]=="last_name"
    # Initialize new user record with non-associated values (column 10-21 or K-V)
    puts row[0]
    @user = User.new(
      #:id => row[0].to_i,
      :last_name => row[0],
      :first_name => row[1],
      # :comments => row[2]
      # :email => row[3],
      :google_scholar => row[4],
      :website => row[5],
      :department => row[6],
      # :organisation_id => row[7],      
      :country => row[8],
      # :address => row[9], NOT USED
      :research_interests => row[10],
      :twitter => row[11],
      :password => row[0] + "_temp",
      :confirmed_at => time = Time.now.getutc
    )
    # TEMPORARY Automatic corrections ___CLEANUP___
    @user.first_name = row[1] if @user.first_name == nil
    @user.email = row[1].gsub(/\s+/, "") + row[0].gsub(/\s+/, "") + "@mesophotic.org"

    # Organisation
    if row[7]
      @user.organisation_id = Organisation.find_or_create_by(name: row[7].strip, 
                                                             country: row[8]).id
    end
    # Link publications
    for publication in Publication.where("authors LIKE ?", "%#{@user.last_name}%")
      # Individually check authors of publication that contains search string
      authors = publication.authors.split(', ')
      for author in authors
        last_name = author.split()[0]
        if last_name == @user.last_name
          @user.publications << publication
        end
      end
    end
    # Link presentations
    for presentation in Presentation.where("authors LIKE ?", "%#{@user.last_name}%")
      # Individually check authors of publication that contains search string
      authors = presentation.authors.split(', ')
      for author in authors
        last_name = author.split()[0]
        if last_name == @user.last_name
          @user.presentations << presentation
        end
      end
    end    
    # Save record
    @user.save!
  end
end

def create_publications
  CSV.foreach("#{::Rails.root}/db/import/publications.csv") do |row|
    # Skip first row
    next if row[0]=="Authors"
    # Initialize new publication record with non-associated values (column 10-21 or K-V)
    @publication = Publication.new(
      :authors =>  row[0],
      :publication_year => row[1].to_i,
      #:title => row[2],
      # :location(_id) => row[3],
      :min_depth => row[4],
      :max_depth => row[5],
      # :technology(_id) => row[6],
      :new_species => row[7],
      # :focus(_id) => row[8],
      # :field(_id) => row[9],
      # :journal_name(_id) => row[10],
      :volume => row[11],
      :issue => row[12],
      :pages => row[13],
      :DOI => row[14],
      :filename => row[15],
      :abstract => row[16],
      :original_data => row[17],
      :mesophotic => row[18]
    )
    # Location (associated value)
    if row[3]
      location_list = row[3].strip.split(";")
        location_list.each do |location_description|
          @location = Location.find_or_create_by(description: location_description.strip)
          @location.save!
          @publication.locations << @location
        end
    end
    # Platform (associated value)
    if row[6]
      platform_list = row[6].strip.split(";")
        platform_list.each do |platform_description|
          @platform = Platform.find_or_create_by(description: platform_description.strip)
          @platform.save!
          @publication.platforms << @platform
        end
    end
    # Focusgroup (associated value)
    if row[8]
      focusgroup_list = row[8].strip.split(";")
        focusgroup_list.each do |focusgroup_description|
          @focusgroup = Focusgroup.find_or_create_by(description: focusgroup_description.strip)
          @focusgroup.save!
          @publication.focusgroups << @focusgroup
        end
    end
    # Field (associated value)
    if row[9]
      field_list = row[9].strip.split(";")
        field_list.each do |field_description|
          @field = Field.find_or_create_by(description: field_description.strip)
          @field.save!
          @publication.fields << @field
        end
    end   
    # Journal (associated value)
    journal_name = row[10]
    @publication.journal_id = Journal.find_or_create_by(name: journal_name).id
    
    # Contents (from separate file)
    filename = row[15]
    if File.exist?("#{::Rails.root}/db/import/contents/#{filename}.txt")
      contents_file = File.open("#{::Rails.root}/db/import/contents/#{filename}.txt", "rb")
      @publication.contents = contents_file.read
    else
      puts "***File not found: #{::Rails.root}/db/import/contents/#{filename}.txt"
    end
    # Assess availability other linked files
    if not File.exist?("#{::Rails.root}/public/images/publications/png/#{filename}.png")
      puts "***File not found: #{::Rails.root}/public/images/publications/png/#{filename}.png"
    end
    #if not File.exist?("#{::Rails.root}/public/images/publications/pdf/#{filename}.pdf")
    #  puts "***File not found: #{::Rails.root}/public/images/publications/pdf/#{filename}.pdf"
    #end
    

    # Save record
    @publication.save!
  end
end

def create_locations
  CSV.foreach("#{::Rails.root}/db/import/locations.csv") do |row|
    # Skip first row
    next if row[0]=="description" 
    @location = Location.new(
      :description => row[0],
      :latitude => row[1].to_d,
      :longitude => row[2].to_d
    )
    @location.save!
  end
end

def create_sites
  CSV.foreach("#{::Rails.root}/db/import/sites.csv") do |row|
    # Skip first row
    next if row[0]=="File name"
    # Skip if coordinates are missing
    next if not row[4]
    # Initialize new site record with non-associated values (column 10-21 or K-V)
    @site = Site.new(
      #filename => row[0],
      #location => row[1],
      #lat_degrees => row[2],
      #lon_degrees => row[3],
      :latitude => row[4].to_d,
      :longitude => row[5].to_d,
      :site_name => row[6],
      #:estimated => row[7],
    )
    # Estimated (convert to Boolean)
    if row[7] == "Estimated"
      @site.estimated = true
    else
      @site.estimated = false
    end
    # Location (associated value)
    if row[1]
      location_description = row[1].strip.split(";")[0]
      @location = Location.find_or_create_by(description: location_description.strip)
      @location.save!
      @site.location_id = @location.id
    end
    @site.save!
    
    # Link to publication (associated value)
    if row[0]
      @publication = Publication.find_by(filename: row[0].strip)
      if @publication
        @publication.sites << @site
        @publication.save!
      else
        puts "***Publication #{row[0]} for site: #{row[6]} not found!"
      end
    else
      puts "***Publication not given for site: #{row[6]}!"
    end
  end
end

def create_presentations
  CSV.foreach("#{::Rails.root}/db/import/presentations.csv") do |row|
    # Skip first row
    @presentation = Presentation.new(
      #:title => row[0],
      :abstract => row[1],
      :authors => row[2],
      :oral => row[3],
      :session => row[4],
      :date => row[5],
      :time => row[6],
      :location => row[7],
      :poster_id => row[8].to_i
    )
    @presentation.save!
  end
end

def create_publications_from_xml
  f = File.open("#{::Rails.root}/db/import/publications.xml")
  doc = Nokogiri::XML(f)
  doc.css('reference').each do |reference|
    @publication = Publication.new()
    
    # Authors: combine into single string
    @formatted_authors = []
    reference.css('author').each do |author|
      @formatted_authors << author.css('surname').inner_text + " " +
        author.css('initials').inner_text
    end
    @publication.authors = @formatted_authors.join(', ')
    # Publication year
    dates = reference.css('date')
    @publication.publication_year = dates.at_css('[type=Publication]')["year"].to_i if dates.at_css('[type=Publication]')

    # Basic fields
    characters = reference.css('characteristic')
    journal_name = characters.css('[name=publicationTitle]').inner_text
    @publication.journal_id = Journal.find_or_create_by(name: journal_name).id
    #@publication.title = characters.css('[name=articleTitle]').inner_text
    @publication.volume = characters.css('[name=volume]').inner_text
    @publication.issue = characters.css('[name=issue]').inner_text
    @publication.pages = characters.css('[name=pages]').inner_text
    @publication.DOI = characters.css('[name=DOI]').inner_text
    @publication.ISSN = characters.css('[name=ISSN]').inner_text
    #@publication.url = characters.css('[name=articleTitle]').inner_text
    #@publication.book_title = characters.css('[name=articleTitle]').inner_text
    #@publication.book_publisher = characters.css('[name=articleTitle]').inner_text
    @publication.abstract = characters.css('[name=abstractText]').inner_text
    @publication.save!
  end
  f.close
end

def reset_passwords
  User.find_each do |user|
    if !user.editor? and !user.admin?
      user.password = user.last_name.downcase.reverse + "_meso"
      user.save!
    end
  end
end