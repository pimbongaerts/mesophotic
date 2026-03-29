class Status
  attr_reader :username, :profile_url, :content, :content_url, :published_at

  def initialize username, profile_url, content, content_url, published_at = nil
    @username, @profile_url, @content, @content_url, @published_at = username, profile_url, content, content_url, published_at
  end
end
