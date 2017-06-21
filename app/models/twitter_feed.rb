class TwitterFeed
    def self.search string
        return @@client.search string
    end

    protected
    
    class FauxClient
        def search string; return []; end
    end

    def self.client
        Twitter::REST::Client.new do |config|
            config.consumer_key    = ENV['TWITTER_KEY']
            config.consumer_secret = ENV['TWITTER_SECRET']
        end
    rescue
        FauxClient.new
    end

    @@client = self.client
end
