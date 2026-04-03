class Rack::Attack
  # Throttle search requests: 20 per minute per IP
  throttle("search/ip", limit: 20, period: 60) do |req|
    req.ip if req.path == "/publications" && req.params["search"].present?
  end

  # Throttle all requests: 120 per minute per IP
  throttle("requests/ip", limit: 120, period: 60) do |req|
    req.ip
  end

  # Block requests with obvious spam patterns in search
  blocklist("spam-searches") do |req|
    if req.path == "/publications" && req.params["search"].present?
      search = req.params["search"].to_s
      # Block searches containing URLs or known spam domains
      search.match?(/https?:\/\/|\.cc\b|\.lol\b|\.shop\b|\.xyz\b|\.top\b|hkcash|sgbot|tf88/i)
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
