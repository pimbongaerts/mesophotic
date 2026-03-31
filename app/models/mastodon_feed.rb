require 'rss'
require 'net/http'
require 'json'

class MastodonFeed
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

    # Fetch profiles in parallel (all at once, ~5s total instead of ~50s)
    threads = @feed.map do |status|
      Thread.new { fetch_profile(status) }
    end
    threads.each(&:join)
  end

  private

  def fetch_profile(status)
    profile_url = status.profile_url.to_s
    content_url = status.content_url.to_s

    # Try Mastodon-style: https://instance/@username
    if (match = profile_url.match(/^(https?:\/\/[^\/]+)\/@(.+)$/))
      instance, username = match[1], match[2]
      data = api_get("#{instance}/api/v1/accounts/lookup", acct: username)
      if data
        status.avatar_url = data["avatar"]
        status.display_name = data["display_name"]
      end
    elsif (match = content_url.match(/^(https?:\/\/[^\/]+)\/notes\/(.+)$/))
      # Non-Mastodon (Misskey/Firefish/etc): fetch status to get account info
      instance, status_id = match[1], match[2]
      data = api_get("#{instance}/api/v1/statuses/#{status_id}")
      if data && data["account"]
        status.avatar_url = data["account"]["avatar"]
        status.display_name = data["account"]["display_name"]
      end
    end
  rescue => e
    # Silently fail — avatar/name just won't be shown
    Rails.logger.debug "MastodonFeed: failed to fetch profile for #{status.username}: #{e.message}"
  end

  def api_get(url, params = {})
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(params) if params.any?
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 5
    response = http.get(uri.request_uri)
    return nil unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  rescue
    nil
  end

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
