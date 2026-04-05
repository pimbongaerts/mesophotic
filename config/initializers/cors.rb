# Allow cross-origin loading of JS modules from assets.mesophotic.org.
# ES modules loaded via importmap require CORS headers, unlike regular script tags.

Rails.application.config.middleware.insert_before 0, Class.new {
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    if env["PATH_INFO"]&.start_with?("/assets/") && env["PATH_INFO"]&.end_with?(".js")
      origin = env["HTTP_ORIGIN"]
      if origin&.match?(/\Ahttps:\/\/(www\.)?mesophotic\.org\z/)
        headers["Access-Control-Allow-Origin"] = origin
      end
    end

    [status, headers, body]
  end
}
