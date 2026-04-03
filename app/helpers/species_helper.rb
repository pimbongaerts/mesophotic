module SpeciesHelper
  def cached_species_image(species)
    return nil unless species.img_url.present?

    Rails.cache.fetch(["species_image", species.id, species.updated_at], expires_in: 24.hours) do
      if species.focusgroup_id == 1 && url_exists?(species.img_url)
        get_fishbase_image(species.img_url)
      elsif species.focusgroup_id == 2 && url_exists?(species.img_url)
        get_cotw_image(species.img_url)
      end
    end
  end

  private

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