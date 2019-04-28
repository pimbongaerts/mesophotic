class PagesController < ApplicationController
  before_action :require_admin_or_editor!, :only => [:inside]

  def home
    @locations = Location.map_data
    @posts = Post.latest(2)
    @publications = Publication.latest(10)
    @latest_update = Publication.maximum(:updated_at)
  end

  def stats
    @users = User.all
    @latest_update = Publication.maximum(:updated_at)
    @publications = Publication.include_in_stats
                               .order('publication_year DESC,
                                       created_at DESC')
    # Search terms
    @publications_total_counts = Publication.select('*, count(id) as publications_count')
                                            .all
                                            .group('publication_year')
    @publications_refug_counts = Publication.relevance('refug')
                                            .select('publication_year, count(id) as publications_count')
                                            .group('publication_year')
    @publications_mesophotic_counts = Publication.relevance('mesophotic')
                                                 .select('publication_year, count(id) as publications_count')
                                                 .group('publication_year')


    @platforms = Platform.joins(:publications)
                         .select('*, count(publications.id) as publications_count')
                         .group('platforms.id')
                         .order('count(platforms.id) DESC')
    @platforms_top = @platforms.limit(10)


    @fields = Field.joins(:publications)
                   .select('*, count(publications.id) as publications_count')
                   .group('fields.id')
                   .order('count(fields.id) DESC')
    @fields_top = @fields.limit(10)

    @focusgroups = Focusgroup.joins(:publications)
                             .select('*, count(publications.id) as publications_count')
                             .group('focusgroups.id')
                             .order('count(focusgroups.id) DESC')
    @focusgroups_top = @focusgroups.limit(10)

    @journals = Journal.joins(:publications)
                         .select('*, count(publications.id) as publications_count')
                         .group('journals.id')
                         .order('count(journals.id) DESC')
    @journals_top = @journals.limit(10)

    @locations = Location.joins(:publications)
                         .select('*, count(publications.id) as publications_count')
                         .group('locations.id')
                         .order('count(locations.id) DESC')
    @locations_top = @locations.limit(25)
    @locations_raw = Location.all

  end

  def inside
  end

  def media_gallery
    @photos = Photo.media_gallery.order('photos.id DESC').page(params[:page])
    @location_counts = Location.joins(:photos)
                               .group('locations.id')
                               .select('locations.*, count(locations.id) as item_count')
  end

  def members
    @users = User.all.order('last_name ASC')
    @publications = Publication.all
  end

  def show_member
    @user = User.find(params[:id])
  rescue
    redirect_to root_path
  end

  def about
    @platforms = Platform.all.order('description ASC')
    @fields = Field.all.order('description ASC')
    @focusgroups = Focusgroup.all.order('description ASC')
    @locations = Location.all.order('description ASC')
  end

  def posts
    @posts = Post.published.page(params[:page]).per(20)
  end

  def show_post
    @post = Post.friendly.find(params[:id])
  rescue
    redirect_to root_path
  end

  def email
    @name = params[:name]
    @email = params[:email]
    @message = params[:message]

    if @name.blank?
      flash[:alert] = 'Please enter your name before sending your message.'
      render :contact
    elsif @email.blank? ||
          @email.scan(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i).size < 1
      flash[:alert] = 'You must provide a valid email address .'
      render :contact
    elsif @message.blank? || @message.length < 10
      flash[:alert] = 'Your message is empty. Requires at least 10 characters.'
      render :contact
    #elsif @message.scan(/<a href=/).size > 0 ||
    #      @message.scan(/\[url=/).size > 0 ||
    #      @message.scan(/\[link=/).size > 0 ||
    #      @message.scan(/http:\/\//).size > 0
    #  flash[:alert] = 'You can't send links unfortunately.'
    #  render :contact
    else
      ContactMailer.contact_message(@name,@email,@message).deliver_now
      redirect_to root_path, notice: 'Your message was sent. Thank you.'
    end
  end
end
