class Rack::Attack
  SPAM_SEARCH_PATTERN = /https?:\/\/|\.cc\b|\.lol\b|\.shop\b|\.xyz\b|\.top\b|\.vip\b|hkcash|sgbot|tf88|bet365|miyao|qqwechat|购买|驾照|毕业证|成绩单|学历认证/i

  # Throttle search requests: 20 per minute per IP
  throttle("search/ip", limit: 20, period: 60) do |req|
    req.ip if req.path == "/publications" && req.params["search"].present?
  end

  # Throttle all requests: 120 per minute per IP
  throttle("requests/ip", limit: 120, period: 60) do |req|
    req.ip
  end

  # Block known spam source IPs
  blocklist("spam-ips") do |req|
    req.ip.start_with?("85.208.96.")
  end

  # Block requests with empty or missing user agents (almost always bots)
  blocklist("no-user-agent") do |req|
    req.user_agent.nil? || req.user_agent.strip.empty?
  end

  # Auto-ban IPs that send spam searches — banned for 1 hour after 2 strikes
  blocklist("fail2ban-spam") do |req|
    Rack::Attack::Fail2Ban.filter("spam-#{req.ip}", maxretry: 2, findtime: 300, bantime: 3600) do
      if req.path == "/publications" && req.params["search"].present?
        req.params["search"].to_s.match?(SPAM_SEARCH_PATTERN)
      end
    end
  end

  # Block requests with obvious spam patterns in search
  blocklist("spam-searches") do |req|
    if req.path == "/publications" && req.params["search"].present?
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
