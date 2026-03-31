require 'net/http'
require 'json'

class BlueskyFeed
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

  API_HOST = "bsky.social".freeze

  attr_reader :feed

  def initialize(hashtag = "mesophotic")
    token = authenticate
    unless token
      @feed = []
      return
    end

    uri = URI.parse("https://#{API_HOST}/xrpc/app.bsky.feed.searchPosts?q=%23#{hashtag}&sort=latest&limit=25")
    response = api_get(uri, token)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      @feed = (data["posts"] || []).map { |post| parse_post(post) }
    else
      Rails.logger.debug "BlueskyFeed: search returned #{response.code}: #{response.body[0..200]}"
      @feed = []
    end
  rescue => e
    Rails.logger.debug "BlueskyFeed: failed to fetch: #{e.message}"
    @feed = []
  end

  private

  def authenticate
    # Cache the session token for 1 hour (tokens last 2 hours)
    Rails.cache.fetch("bluesky_session_token", expires_in: 1.hour) do
      handle = Rails.application.credentials.dig(:bluesky, :handle)
      app_password = Rails.application.credentials.dig(:bluesky, :app_password)

      unless handle.present? && app_password.present?
        Rails.logger.debug "BlueskyFeed: bluesky credentials not configured"
        return nil
      end

      uri = URI.parse("https://#{API_HOST}/xrpc/com.atproto.server.createSession")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 5

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request.body = { identifier: handle, password: app_password }.to_json

      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        data["accessJwt"]
      else
        Rails.logger.debug "BlueskyFeed: auth failed #{response.code}: #{response.body[0..200]}"
        nil
      end
    end
  rescue => e
    Rails.logger.debug "BlueskyFeed: auth error: #{e.message}"
    nil
  end

  def api_get(uri, token)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri.request_uri)
    request["Authorization"] = "Bearer #{token}"
    http.request(request)
  end

  def parse_post(post)
    author = post["author"] || {}
    record = post["record"] || {}

    status = Status.new(
      author["handle"],
      "https://bsky.app/profile/#{author["did"]}",
      format_content(record["text"], record["facets"]),
      post_url(author["handle"], post["uri"]),
      record["createdAt"] ? Time.parse(record["createdAt"]) : nil
    )
    status.avatar_url = author["avatar"]
    status.display_name = author["displayName"]
    status
  end

  def post_url(handle, at_uri)
    rkey = at_uri.to_s.split("/").last
    "https://bsky.app/profile/#{handle}/post/#{rkey}"
  end

  def format_content(text, facets)
    return "" if text.nil?

    if facets.nil? || facets.empty?
      return ERB::Util.html_escape(text).gsub("\n", "<br>")
    end

    result = text.dup
    sorted_facets = facets.sort_by { |f| -(f.dig("index", "byteStart") || 0) }

    sorted_facets.each do |facet|
      byte_start = facet.dig("index", "byteStart")
      byte_end = facet.dig("index", "byteEnd")
      next unless byte_start && byte_end

      feature = (facet["features"] || []).first
      next unless feature

      original_bytes = text.bytes[byte_start...byte_end]
      next unless original_bytes
      original_text = original_bytes.pack("C*").force_encoding("UTF-8")
      escaped_text = ERB::Util.html_escape(original_text)

      replacement = case feature["$type"]
      when "app.bsky.richtext.facet#link"
        url = feature["uri"]
        "<a href=\"#{ERB::Util.html_escape(url)}\" target=\"_blank\" rel=\"noopener\">#{escaped_text}</a>"
      when "app.bsky.richtext.facet#mention"
        did = feature["did"]
        "<a href=\"https://bsky.app/profile/#{ERB::Util.html_escape(did)}\" target=\"_blank\" rel=\"noopener\">#{escaped_text}</a>"
      when "app.bsky.richtext.facet#tag"
        tag = feature["tag"]
        "<a href=\"https://bsky.app/hashtag/#{ERB::Util.html_escape(tag)}\" target=\"_blank\" rel=\"noopener\">#{escaped_text}</a>"
      else
        escaped_text
      end

      result_bytes = result.bytes.to_a
      replacement_bytes = replacement.bytes.to_a
      result_bytes[byte_start...byte_end] = replacement_bytes
      result = result_bytes.pack("C*").force_encoding("UTF-8")
    end

    result.gsub("\n", "<br>")
  end
end
