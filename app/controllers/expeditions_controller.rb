class ExpeditionsController < ApplicationController
  before_action :require_admin_or_editor!, :except => [:show, :index]
  before_action :set_expedition, only: [:show, :edit, :update, :destroy]

  def index
    @expeditions = Expedition.all
  end

  def show
    # TODO
  end

  def new
    @expedition = Expedition.new
  end

  def edit
  end

  def create
    @expedition = Expedition.new(expedition_params)

    respond_to do |format|
      if @expedition.save
        format.html { redirect_to @expedition, 
                      notice: 'Expedition was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @expedition.update(expedition_params)
        format.html { redirect_to @expedition, 
                      notice: 'Expedition was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @expedition.destroy
    respond_to do |format|
      format.html { redirect_to expeditions_url, 
                    notice: 'Expedition was successfully destroyed.' }
    end
  end

  private
    def set_expedition
      @expedition = Expedition.find(params[:id])
    end

    def expedition_params
      params.require(:expedition).permit(:title, 
                                         :description, 
                                         :year, 
                                         :start_date, 
                                         :end_date, 
                                         :url,
                                         :featured_image,
                                         :featured_image_credits,
                                         {:user_ids => []},
                                         {:organisation_ids => []},
                                         {:platform_ids => []},
                                         {:field_ids => []},
                                         {:focusgroup_ids => []},
                                         {:location_ids => []})
    end
end
