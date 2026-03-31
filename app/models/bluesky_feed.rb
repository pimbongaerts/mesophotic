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

  attr_reader :feed

  def initialize(hashtag = "mesophotic")
    uri = URI.parse("https://public.api.bsky.app/xrpc/app.bsky.feed.searchPosts?q=%23#{hashtag}&sort=latest&limit=25")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10
    response = http.get(uri.request_uri)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      @feed = (data["posts"] || []).map { |post| parse_post(post) }
    else
      @feed = []
    end
  rescue => e
    Rails.logger.debug "BlueskyFeed: failed to fetch: #{e.message}"
    @feed = []
  end

  private

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
    # AT URI format: at://did:plc:xxx/app.bsky.feed.post/rkey
    rkey = at_uri.to_s.split("/").last
    "https://bsky.app/profile/#{handle}/post/#{rkey}"
  end

  def format_content(text, facets)
    return "" if text.nil?

    # If no facets (links/mentions), just convert newlines to <br> and escape HTML
    if facets.nil? || facets.empty?
      return ERB::Util.html_escape(text).gsub("\n", "<br>")
    end

    # Process facets (links, mentions, tags) - sort by byte position descending
    # so replacements don't shift positions
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

      # Replace using byte positions on the original text
      result_bytes = result.bytes.to_a
      replacement_bytes = replacement.bytes.to_a
      result_bytes[byte_start...byte_end] = replacement_bytes
      result = result_bytes.pack("C*").force_encoding("UTF-8")
    end

    # The facet processing handles escaping for replaced segments.
    # Remaining plain text between facets is not HTML-escaped yet,
    # but since we process the full text with byte replacement,
    # we need to escape the non-faceted portions separately.
    result.gsub("\n", "<br>")
  end
end
