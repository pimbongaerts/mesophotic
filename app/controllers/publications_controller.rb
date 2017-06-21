class PublicationsController < ApplicationController
  require 'will_paginate/array' # in order to paginate static array

  before_action :require_admin_or_editor!, :except => [:show, :index, :behind]
  before_action :set_publication, only: [:show, :edit, :edit_meta, :update, 
                                         :behind, :destroy, :detach_field,
                                         :detach_focusgroup, :detach_platform,
                                         :detach_location, :add_validation,
                                         :remove_validation, :touch_validation]
  before_action :touch_publication, only: [:detach_field, :detach_focusgroup, 
                                           :detach_platform, :detach_location]
  before_action :contents_convert_utf8, only: [:edit]
  before_action :empty_unused_fields, only: [:edit, :edit_meta, :update]


  def index
    @sites = Site.all ###REMOVE
    @publications = Publication.all
    if params[:scientific]
      @publications = @publications.where(publication_type: 'scientific')
    end
    if params[:validated] || params[:validation_type] == 'validated'
      @publications = @publications
        .select('publications.*, count(validations.id) AS validations_count')
        .joins(:validations)
        .where('validations.updated_at >= publications.updated_at')
        .group('publications.id')
        .having('validations_count > 2')
    
    elsif params[:validation_type] == 'expired'
      @publications = @publications
        .select('publications.*')
        .joins(:validations)
        .where('validations.user_id = ? AND 
                validations.updated_at < publications.updated_at', 
                current_user.id)
        .group('publications.id')

    #elsif params[:validation_type] == 'unvalidated'
    elsif params[:search].blank?    
      # Provide access to top 10 values of linked models
      @locations = Location.joins(:publications).group('locations.id')
                    .order('count(locations.id) DESC')
      @platforms = Platform.joins(:publications).group('platforms.id')
                    .order('count(platforms.id) DESC')
      @focusgroups = Focusgroup.joins(:publications).group('focusgroups.id')
                      .order('count(focusgroups.id) DESC')
      @fields = Field.joins(:publications).group('fields.id')
                  .order('count(fields.id) DESC')
      @publications = @publications.order('filename ASC')
    # Show only record that match search term
    else
      @publications = @publications.search(params[:search])
      @publications = sort_by_relevance(@publications, params[:search])
    end

    if request.format.html? && !current_user.try(:editor_or_admin?)
      @publications = @publications
                        .paginate(:page => params[:page], 
                                  :per_page => 20)
    end

    respond_to do |format|
      format.html {  }
      format.csv { send_data @publications.to_csv }
    end
  end

  def show
  end

  def behind
  end

  def new
    @publication = Publication.new
  end

  def edit
  end

  def edit_meta
  end

  def create
    @publication = Publication.new(publication_params)

    respond_to do |format|
      if @publication.save
        format.html { redirect_to edit_meta_publication_path(@publication), 
                      notice: 'Publication was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @publication.update(publication_params)
        format.html { redirect_to :back, 
                      notice: 'Publication was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @publication.destroy
    respond_to do |format|
      format.html { redirect_to :back, 
                    notice: 'Publication was successfully destroyed.' }
    end
  end

  def detach_field
      @publication.fields.delete(params[:format])
      redirect_to :back, notice: 'Field was successfully removed.'
  end

  def detach_focusgroup
      @publication.focusgroups.delete(params[:format])
      redirect_to :back, notice: 'Focusgroup was successfully removed.'
  end

  def detach_platform
      @publication.platforms.delete(params[:format])
      redirect_to :back, notice: 'Platform was successfully removed.'
  end

  def detach_location
      @publication.locations.delete(params[:format])
      redirect_to :back, notice: 'Location was successfully removed.'
  end

  def add_validation
      @publication.validations.build(user_id: params[:format]).save!
      redirect_to :back, notice: 'Publication was successfully validated.'
  end

  def remove_validation
      @publication.validations.find_by_user_id(params[:format]).delete
      redirect_to :back, notice: 'Validation was successfully removed.'
  end

  def touch_validation
      @publication.validations.find_by_user_id(params[:format]).touch
      redirect_to :back, notice: 'Publication was successfully revalidated.'
  end

  private
    def set_publication
      @publication = Publication.find(params[:id])
    end

    def touch_publication
      @publication.touch
    end

    # Convert contents to utf8 format to avoid errors in forms
    def contents_convert_utf8
      @publication.title = @publication.title.force_encoding('UTF-8')
      @publication.abstract = @publication.abstract.force_encoding('UTF-8')
      @publication.contents = @publication.contents.force_encoding('UTF-8')
    end

    # Depending on publication_type, empty fields that are not being used
    def empty_unused_fields
      if @publication.scientific_article?
        # Empty fields specific to categories other than scientific_article
        @publication.book_title = ''
        @publication.book_authors = ''
        @publication.book_publisher = ''
        @publication.url = ''
      else
        # Empty fields specific to scientific_article
        @publication.journal_id = 0
        @publication.new_journal_name = ''
        @publication.DOI = ''
        @publication.volume = ''
        @publication.issue = ''
        @publication.pages = ''
        unless @publication.chapter?
          # Empty fields specific to book_chapter
          @publication.book_title = ''
          @publication.book_authors = ''
        end
      end
    end

    # Sort list of publications by frequency of search term in full text
    def sort_by_relevance(publications, search_term)
      # Obtain search term frequency in each publication
      publication_wordfreq = Hash.new(0)
      publications.each do |pub|
        publication_wordfreq[pub] = pub.occurrence_in_contents(search_term)
      end
      # Order hash by search term frequency
      publication_wordfreq = publication_wordfreq.sort_by {|x,y| y }
      publication_wordfreq.reverse!
      publication_wordfreq.collect {|key,value| key }
    end

    def publication_params
      params.require(:publication).permit(
      :title,
      :authors,
      :publication_year,
      :journal_id,
      :publication_type,
      :publication_format,
      :new_journal_name,
      :volume,
      :issue,
      :pages,
      :DOI,
      :abstract,
      :contents,
      :min_depth,
      :max_depth,
      :mce,
      :original_data,
      :mesophotic,
      :new_species,
      :filename,
      :book_title,
      :book_publisher,
      :book_authors,
      :url,
      :pdf,
      :validations,
      {:platform_ids => []},
      {:field_ids => []},
      {:location_ids => []},
      {:focusgroup_ids => []},
      {:user_ids => []}
      )
    end
end