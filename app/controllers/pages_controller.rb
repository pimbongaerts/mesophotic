class PagesController < ApplicationController
  before_action :require_admin_or_editor!, :only => [:inside]

  def home
    @locations = Location.published
    @posts = Post.latest(2).includes(photos: { image_attachment: :blob })
    @publications = Publication.latest(20).includes(:users, :journal)
    @latest_update = Publication.maximum(:updated_at)
  end

  def mastodon_feed
    statuses, users = Rails.cache.fetch(["mastodon_feed", User.maximum(:updated_at)], expires_in: 1.hour) do
      s = StatusFeed.new("https://mastodon.social/tags/mesophotic.rss").take(10)
      u = User.where(twitter: s.map(&:username))
      [s, u]
    end
    render partial: 'mastodon_feed', locals: { statuses: statuses, users: users }
  end

  def inside
  end

  def media_gallery
    @photos = Photo.media_gallery.order(id: :desc).page(params[:page])
  end

  def members
    @users = User.all.order(last_name: :asc).includes(:publications, :organisation)
    @publications = Publication.all
    @latest_members = User.order(updated_at: :desc).includes(:publications).limit(15)
    @featured_member = User.joins(:publications)
                           .where.not(publications: { id: nil })
                           .joins(:profile_picture_blob)
                           .where.not(active_storage_blobs: { filename: nil })
                           .where(admin: false)
                           .includes(:organisation, profile_picture_attachment: :blob)
                           .distinct
                           .order(Arel.sql("RANDOM()"))
                           .first
  end

  def show_member
    @user = User.includes(:organisation, :platforms, profile_picture_attachment: :blob).find(params[:id])
  rescue
    redirect_to root_path
  end

  def about
    @platforms = Platform.all.order(description: :asc)
    @fields = Field.all.order(description: :asc)
    @focusgroups = Focusgroup.all.order(description: :asc)
    @locations = Location.all.order(description: :asc)
    @users_by_name = User.includes(:organisation, profile_picture_attachment: :blob)
                         .index_by { |u| "#{u.first_name} #{u.last_name}" }
  end

  def posts
    @posts = Post.published.includes(:user, :featured_user, :featured_publication, photos: { image_attachment: :blob }).page(params[:page]).per(20)
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
    cached = Rails.cache.fetch(["member_keywords", params[:id], Publication.maximum(:updated_at)]) do
      publications = Publication.select(:contents).joins(:users).where("users.id == ?", params[:id])
      word_cloud = publications.word_cloud(40)
      word_cloud.present? ? render_to_string(partial: 'shared/wordcloud', object: word_cloud, locals: { title: 'publication_contents' }) : ""
    end
    render html: cached.html_safe
  end

  def member_research_summary
    render partial: 'research_summary', locals: { user: User.find(params[:id]) }
  end
end
