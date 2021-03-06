class Admin::BaseController < ApplicationController
  before_action :require_admin!

  def index
    @last_signups = User.last_signups(10)
    @last_signins = User.last_signins(10)
    @count = User.users_count
    @post_count = Post.count
    @publication_count = Publication.count
  end
end
