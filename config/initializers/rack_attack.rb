class Rack::Attack
  SPAM_SEARCH_PATTERN = /[\u4e00-\u9fff]|[\u3040-\u309f]|[\u30a0-\u30ff]|[\uac00-\ud7af]|https?:\/\/|\.cc\b|\.lol\b|\.shop\b|\.xyz\b|\.top\b|\.vip\b|\.club\b|hkcash|sgbot|tf88|bet365|miyao|qqwechat|spiderpools|usdtcard|1024dhz|666bit|777bd/i

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

  # Log all Rack::Attack actions
  ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _id, payload|
    req = payload[:request]
    match_type = req.env["rack.attack.match_type"]
    rule = req.env["rack.attack.matched"]
    ip = req.ip

    case match_type
    when :blocklist
      Rails.logger.warn("[Rack::Attack] Blocked #{ip} (#{rule}) #{req.request_method} #{req.fullpath}")
    when :throttle
      data = req.env["rack.attack.match_data"]
      Rails.logger.warn("[Rack::Attack] Throttled #{ip} (#{rule}) #{data[:count]}/#{data[:limit]} #{req.request_method} #{req.fullpath}")
    end
  end
end
