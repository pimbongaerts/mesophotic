class Rack::Attack
  SPAM_SEARCH_PATTERN = /https?:\/\/|\.cc\b|\.lol\b|\.shop\b|\.xyz\b|\.top\b|\.vip\b|\.net\b|hkcash|sgbot|tf88|bet365|miyao|qqwechat|购买|驾照|毕业证|成绩单|学历认证|色情|娛樂城|188金寶博/i

  # Throttle search requests: 20 per minute per IP
  throttle("search/ip", limit: 20, period: 60) do |req|
    req.ip if req.path.start_with?("/publications") && req.params["search"].present?
  end

  # Throttle page requests: 300 per minute per IP (excludes images/assets)
  throttle("requests/ip", limit: 300, period: 60) do |req|
    req.ip unless req.path.match?(/\.(jpg|jpeg|png|gif|svg|ico|css|js|woff2?|ttf|eot|map|webp)$/i)
  end

  # Block known spam source IPs
  blocklist("spam-ips") do |req|
    req.ip.start_with?("85.208.96.")
  end

  # Block requests with obvious spam patterns in search
  blocklist("spam-searches") do |req|
    if req.path.start_with?("/publications") && req.params["search"].present?
      req.params["search"].to_s.match?(SPAM_SEARCH_PATTERN)
    end
  end

  # Return 429 for throttled requests
  self.throttled_responder = lambda do |env|
    [429, { "Content-Type" => "text/plain" }, ["Rate limit exceeded. Try again later.\n"]]
  end

  # Return 403 for blocked requests
  self.blocklisted_responder = lambda do |env|
    [403, { "Content-Type" => "text/plain" }, ["Forbidden.\n"]]
  end
end
