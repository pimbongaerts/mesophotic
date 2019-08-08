module SpeciesHelper
	def get_fishbase_image(url)
		thumbnail_path = Nokogiri::HTML(open(url)).css('img').map { |i| i['src'] }.last

		if thumbnail_path.present?
			image_url = URI.parse(url).merge(URI.parse(thumbnail_path)).to_s.sub(/thumbnails\/(gif|jpg)/, "species").sub(/tn_/, "")
		end

		image_url
	end

	def get_cotw_image(url)
		thumbnail_path = Nokogiri::HTML(open(url)).css('img').map { |i| i['src'] }[5] rescue nil
		
		if thumbnail_path.present?
			image_url = URI.parse(url).merge(URI.parse(thumbnail_path)).to_s.sub(/thumbnail/, "preview")
		end

		return image_url
	end
end