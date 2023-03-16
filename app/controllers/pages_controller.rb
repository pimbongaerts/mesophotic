class PagesController < ApplicationController
  before_action :require_admin_or_editor!, :only => [:inside]

  def home
    @locations = Location.published
    @posts = Post.latest(2)
    @publications = Publication.latest(10)
    @latest_update = Publication.maximum(:updated_at)
  end

  def inside
  end

  def media_gallery
    @photos = Photo.media_gallery.order('photos.id DESC').page(params[:page])
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

  def member_keywords
    publications = Publication.select(:contents).joins(:users).where("users.id == ?", params[:id])
    word_cloud = publications.word_cloud(40)

    if word_cloud.present?
      render partial: 'shared/wordcloud',
             object: word_cloud,
             locals: { title: 'publication_contents' }
    end
  end

  def member_research_summary
    render partial: 'research_summary', locals: { user: User.find(params[:id]) }
  end
end
