class SitesController < ApplicationController
  before_action :require_admin_or_editor!, :except => [:show, :index, :site_keywords, :site_research_details]
  before_action :set_site, only: [:show, :edit, :update, :destroy, :site_research_details]

  def index
    @sites = Site.all.order('site_name ASC')
  end

  def show
  end

  def new
    @site = Site.new
  end

  def edit
  end

  def create
    @site = Site.new(site_params)

    respond_to do |format|
      if @site.save
        format.html { redirect_to @site, 
                      notice: 'Site was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @site.update(site_params)
        format.html { redirect_to @site, 
                      notice: 'Site was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @site.destroy
    respond_to do |format|
      format.html { redirect_to sites_url, 
                    notice: 'Site was successfully destroyed.' }
    end
  end

  def site_keywords
    publications = Publication.select(:contents).joins(:sites).where("sites.id == ?", params[:id])
    word_cloud = publications.word_cloud(40)

    if word_cloud.present?
      render partial: 'shared/wordcloud',
             object: word_cloud,
             locals: { key: publications.key, title: 'location_publication_contents' }
    end
  end

  def site_research_details
    render partial: 'research_details', object: @site.publications
  end

  private
    def set_site
      @site = Site.find(params[:id])
    end

    def site_params
      params.require(:site).permit(:site_name, 
                                   :latitude, 
                                   :longitude,
                                   :location_id)
    end
end
