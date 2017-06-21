class PresentationsController < ApplicationController
  before_action :require_admin_or_editor!, :except => [:show, :index]
  before_action :set_presentation, only: [:show, :edit, :update, :destroy]

  def index
    @presentations = Presentation.all.order('date ASC, time ASC')
  end

  def show
  end

  def new
    @presentation = Presentation.new
  end

  def edit
  end

  def create
    @presentation = Presentation.new(presentation_params)

    respond_to do |format|
      if @presentation.save
        format.html { redirect_to @presentation, 
                      notice: 'Presentation was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @presentation.update(presentation_params)
        format.html { redirect_to @presentation, 
                      notice: 'Presentation was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @presentation.destroy
    respond_to do |format|
      format.html { redirect_to presentations_url, 
                    notice: 'Presentation was successfully destroyed.' }
    end
  end

  private
    def set_presentation
      @presentation = Presentation.find(params[:id])
    end

    def presentation_params
      params.require(:presentation).permit(:title, 
                                           :abstract, 
                                           :authors, 
                                           :oral, 
                                           :session, 
                                           :date, 
                                           :time, 
                                           :location, 
                                           :poster_id,
                                           :meeting_id)
    end
end
