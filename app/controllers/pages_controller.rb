class PagesController < ApplicationController
  before_action :require_admin_or_editor!, :only => [:inside]

  def home
    @users = User.all
    @publications = Publication.all.order('publication_year DESC, 
                                           created_at DESC')
    @locations = Location.joins(:publications).group('locations.id').
                 order('count(locations.id) DESC')
    @focusgroups = Focusgroup.all
    @twitter_feed = TwitterFeed.search("#mesophotic -filter:retweets").take(6)
    @latest_update = Publication.maximum(:updated_at)
  end

  def stats
    @users = User.all
    @latest_update = Publication.maximum(:updated_at)
    @publications = Publication.all.order('publication_year DESC, 
                                           created_at DESC')
  end

  def inside
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
    @posts = Post.published.page(params[:page]).per(10)
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
