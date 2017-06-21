class MeetingsController < ApplicationController
  before_action :require_admin_or_editor!, :except => [:show, :index]
  before_action :set_meeting, only: [:show, :edit, :update, :destroy]

  def index
    @meetings = Meeting.all
  end

  def show
  end

  def new
    @meeting = Meeting.new
  end

  def edit
  end

  def create
    @meeting = Meeting.new(meeting_params)

    respond_to do |format|
      if @meeting.save
        format.html { redirect_to @meeting, 
                      notice: 'Meeting was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @meeting.update(meeting_params)
        format.html { redirect_to @meeting, 
                      notice: 'Meeting was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @meeting.destroy
    respond_to do |format|
      format.html { redirect_to meetings_url, 
                    notice: 'Meeting was successfully destroyed.' }
    end
  end

  private
    def set_meeting
      @meeting = Meeting.find(params[:id])
    end

    def meeting_params
      params.require(:meeting).permit(:title, 
                                      :description, 
                                      :year, 
                                      :start_date, 
                                      :end_date, 
                                      :url,
                                      :featured_image,
                                      :featured_image_credits,
                                      :country,
                                      :venue,
                                      {:user_ids => []},
                                      {:organisation_ids => []},
                                      {:presentation_ids => []})
    end
end
