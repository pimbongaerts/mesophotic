module SpeciesHelper
  def get_fishbase_image(url)
    thumbnail_path = Nokogiri::HTML(URI.open(url)).css('img').map { |i| i['src'] }.last

    if thumbnail_path.present?
      URI.parse(url).merge(URI.parse(thumbnail_path)).to_s.sub(/thumbnails\/(gif|jpg)/, "species").sub(/tn_/, "")
    end
  rescue OpenURI::HTTPError, Errno::ECONNREFUSED, SocketError, Timeout::Error
    nil
  end

  def get_cotw_image(url)
    thumbnail_path = Nokogiri::HTML(URI.open(url)).css('img').map { |i| i['src'] }[5]

    if thumbnail_path.present?
      URI.parse(url).merge(URI.parse(thumbnail_path)).to_s.sub(/thumbnail/, "preview")
    end
  rescue OpenURI::HTTPError, Errno::ECONNREFUSED, SocketError, Timeout::Error
    nil
  end
end