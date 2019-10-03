class TwitterFeed
    def self.search string
        @@client.search string
    rescue
        []
    end

    protected

    class FauxClient
        def search string; return []; end
    end

    def self.client
        Twitter::REST::Client.new do |config|
            config.consumer_key    = Rails.application.credentials.dig(:twitter, :consumer_key)
            config.consumer_secret = Rails.application.credentials.dig(:twitter, :consumer_secret)
        end
    rescue
        FauxClient.new
    end

    @@client = self.client
end
