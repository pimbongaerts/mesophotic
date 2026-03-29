require 'rss'
class StatusFeed
  extend Forwardable
  delegate [
    :each,
    :filter_map,
    :first,
    :flat_map,
    :inject,
    :last,
    :map,
    :reduce,
    :select,
    :take,
  ] => :@feed

  attr_reader :feed

  def initialize url
    URI.open url do |rss|
      @feed = (RSS::Parser.parse rss).channel.items
        .reject { |item| item.categories.map(&:content).include? "introduction" }
        .map { |item|
          uri = URI.parse(item.link)
          username = extract_username(uri)
          profile_url = extract_profile_url(uri, username)

          Status.new(
            username,
            profile_url,
            item.description,
            uri,
            item.pubDate
          )
        }
    end
  end

  private

  def extract_username(uri)
    case uri.path
    when /\/@([^\/]+)/          # Mastodon, Pleroma, GoToSocial, Akkoma
      $1
    when /\/users\/([^\/]+)/    # Some Pleroma instances
      $1
    when /\/notes\//            # Misskey, Firefish, Sharkey
      uri.host
    when /\/objects\//           # Hubzilla, Friendica
      uri.host
    else
      uri.host
    end
  end

  def extract_profile_url(uri, username)
    case uri.path
    when /\/@([^\/]+)/
      URI.parse("#{uri.scheme}://#{uri.host}/@#{username}")
    when /\/users\/([^\/]+)/
      URI.parse("#{uri.scheme}://#{uri.host}/users/#{username}")
    else
      URI.parse("#{uri.scheme}://#{uri.host}/")
    end
  end
end
