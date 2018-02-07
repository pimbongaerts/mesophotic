class PhotosController < ApplicationController
  before_action :require_admin_or_editor!, :except => [:show, :index]
  before_action :set_photo, only: [:show, :edit, :update, :destroy]

  def new
  	@photo = Photo.new
  end

  def index
    @photos = Photo.all.order('photos.id DESC').page(params[:page])
    @location_counts = Location.joins(:photos)
                               .group('locations.id')
                               .select('locations.*, count(locations.id) as item_count')
  end

  def edit
  end

  def show
  end

  def create
    @photo = Photo.new(photo_params)

    respond_to do |format|
      if @photo.save
        format.html { redirect_to edit_photo_path(@photo),
                      notice: 'Photo was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_back fallback_location: root_path,
                      notice: 'Photo was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @photo.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path,
                    notice: 'Photo was successfully destroyed.' }
    end
  end

  private
    def set_photo
      @photo = Photo.find(params[:id])
    end

    def photo_params
      params.require(:photo).permit(:contains_species,
                                  :creative_commons,
	                                :credit,
	                                :depth,
	                                :description,
	                                :expedition_id,
	                                :image,
	                                :location_id,
                                  :meeting_id,
	                                :organisation_id,
	                                :photographer_id,
                                  :post_id,
                                  :publication_id,
	                                :site_id,
                                  :underwater,
	                                :user_id,
                                  {:platform_ids => []},
                                  {:organisation_ids => []},
                                  {:user_ids => []})
    end
end
