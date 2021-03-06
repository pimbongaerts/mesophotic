# Locations controller
class LocationsController < ApplicationController
  before_action :require_admin_or_editor!, :except => [:show, :index]
  before_action :set_location, only: [:edit, :update, :destroy, :detach_publication]

  def index
  	# TODO: had to use `all` rather than `find_each` as offset
  	# for featured_publication did otherwise not work
    @locations = Location.joins(:publications).group('locations.id').order('description ASC')
    @featured_photo = Photo.showcases_location.offset(offset = rand(Photo.showcases_location.count)).first
    @featured_location = @featured_photo.location
  end

  def new
    @location = Location.new
  end

  def edit
  end

  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to edit_location_path(@location),
                      notice: 'Location was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to edit_location_path(@location),
                      notice: 'Location was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url,
                    notice: 'Location was successfully destroyed.' }
    end
  end

  def detach_publication
      @publication = Publication.find(params[:publication_id])
      @publication.locations.delete(params[:id])
      redirect_back fallback_location: root_path,
                    notice: 'Category was successfully removed.'
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:description, :latitude, :longitude)
  end
end
