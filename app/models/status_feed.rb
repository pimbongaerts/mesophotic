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
          Status.new(
            item.link[/\@(.*?)\//, 1],
            (URI.parse item.link.split('/')[0..-2].join('/')),
            item.description,
            (URI.parse item.link)
          )
        }
    end
  end
end

class Status
  attr_reader :username, :profile_url, :content, :content_url

  def initialize username, profile_url, content, content_url
    @username, @profile_url, @content, @content_url = username, profile_url, content, content_url
  end
end
