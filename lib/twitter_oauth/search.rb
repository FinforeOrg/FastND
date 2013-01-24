require 'open-uri'

module TwitterOAuth
  class Client

    def search(q, args={})
      options = args
      options.delete(:callback)
      if @api_version.to_f > 1
        options[:count] = options[:rpp] ||= 20
        options.delete(:rpp)
        options.delete(:page)
        options[:q] = CGI.escape(q)
      else
        options[:page] ||= 1
        options[:rpp] ||= 20
        options[:q] = URI.escape(q)
      end
      
      args = options.map{|k,v| "#{k}=#{v}"}.join('&')
      search_get(search_path(args))
    end

    # Returns the current top 10 trending topics on Twitter.
    def current_trends
      search_get("/trends/current.json")
    end

    # Returns the top 20 trending topics for each hour in a given day.
    def daily_trends
      search_get("/trends/daily.json")
    end

    # Returns the top 30 trending topics for each day in a given week.
    def weekly_trends
      search_get("/trends/weekly.json")
    end

    private
      def search_get(path)
        return search_get_non_api(path) unless @api_version.to_f > 1
        get("#{path}")
      end

      def search_get_non_api(path)
        response = open("http://#{@search_host}#{path}", 'User-Agent' => "twitter_oauth gem v#{TwitterOAuth::VERSION}")
        JSON.parse(response.read)
      end

      def search_path(args)
        return "/search/tweets.json?#{args}" if @api_version.to_f > 1
        "/search.json?#{args}"
      end
  end
end