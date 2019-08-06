module SpeciesHelper
	def get_fishbase_image(url)
		doc = Nokogiri::HTML(open(url))
		img_urls = Array.new
		img_urls = doc.css('img').map{ |i| i['src'] }
		if img_urls.length > 0
			URI.parse(url).merge(URI.parse(img_urls.last)).to_s.sub("thumbnails/jpg", "species").sub("tn_", "")
		end
	end

	def get_cotw_image(url)
		doc = Nokogiri::HTML(open(url))
		img_urls = Array.new
		img_captions = Array.new
		img_urls = doc.css('img').map{ |i| i['src'] }
		img_captions = doc.css('img').map{ |i| i['alt'] }
		if img_urls.length > 0
			img_url = URI.parse(url).merge(URI.parse(img_urls[5])).to_s.sub("thumbnail", "preview")
		end
		return img_url
	end
end