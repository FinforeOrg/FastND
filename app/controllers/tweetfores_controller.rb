class TweetforesController < ApplicationController
  before_filter :prepare_feed_token

  def home_timeline
    tweets = @tweetfore ? @tweetfore.home_timeline(params) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def mentions
    tweets = @tweetfore ?  @tweetfore.mentions(params) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def search
    callback = params[:callback]
    tweets = @tweetfore ? @tweetfore.search(params[:q],params) : error_object("Invalid Token or Reference")
    params[:callback] = callback
    respond_to do |format|
      respond_to_do(format,formated_old_tweets(tweets))
    end
    # rescue => e
    #   respond_rescue(e)
  end

  def messages_inbox
    tweets = @tweetfore ? @tweetfore.messages(params) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def messages_sentbox
    tweets = @tweetfore ? @tweetfore.sent_messages(params) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def message_destroy
    tweets = @tweetfore ? @tweetfore.message_destroy(params[:message_id]) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def message_post
    tweets = @tweetfore ? @tweetfore.message(params[:user],params[:text]) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def status_update
    message = params[:status]
    params.delete(:status)
    tweets = @tweetfore ? @tweetfore.update(message,params) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def status_destroy
    tweets = @tweetfore ? @tweetfore.status_destroy(params[:status_id]) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def status_retweet
    tweets = @tweetfore ? @tweetfore.retweet(params[:status_id]) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def friends
    params[:page] = 1 if params[:page].blank?
    tweets = @tweetfore ? @tweetfore.friends(params[:page].to_i) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def followers
    params[:page] = 1 if params[:page].blank?
    tweets = @tweetfore ? @tweetfore.followers(params[:page].to_i) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def friend_add
    tweets = @tweetfore ? @tweetfore.friend(params[:friend_id]) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def friend_remove
    tweets = @tweetfore ? @tweetfore.unfriend(params[:friend_id]) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def friends_pending    
    tweets = @tweetfore ? @tweetfore.friend_incoming : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  def followers_pending
    tweets = @tweetfore ? @tweetfore.friend_outgoing : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
  end

  private
    def respond_rescue(e)
      respond_to do |format|
        format.json { render :json => e,:status => 200}
      end
    end

    def prepare_feed_token
      api = FeedApi.auth_by("twitter")
      if api
        @twitter_api = api.api
        @twitter_secret = api.secret
      else
        make_api
      end
      
      if params[:feed_account_id]
        feed_account = current_user.feed_accounts.find(params[:feed_account_id])
		    @feed_token = feed_account.feed_token
      elsif params[:action] == "search"
        feed_account = current_user.feed_accounts.where({"feed_token" => {"$ne" => nil}, :category => "twitter"}).shuffle.first
        @feed_token = feed_account.feed_token
      end
      @page = params[:page].to_i
      oauth_options = {consumer_key: @twitter_api, consumer_secret: @twitter_secret, token: @feed_token.token, secret: @feed_token.secret}
      oauth_options.merge!(api_version: "1.1", search_host: "api.twitter.com") #if params[:action] == "search"
      @tweetfore = TwitterOAuth::Client.new(oauth_options) if @feed_token
      params.delete(:feed_token_id)
      params.delete(:feed_account_id)
      params.delete(:auth_token)
      params.delete(:auth_secret)
      #rescue => e
      # respond_rescue(e)
    end

    def make_api
      @linkedin_api = 't_4wFj-MqkExvbTSoRGButHzVA44kwnsaJnswD63RCHeWet7B4N9REyo6pMtztA5'
      @linkedin_secret = 'TPHkKZdW_Wt1Mc_TScbj9e5eSzHHs62ERCDB1kVTKXlQwivapUaOP0Tw_1NcGOq9'
      @twitter_api = 'RhXx78t99jxXAf44NwY4w'
      @twitter_secret = 'ty0AhbgCaDQULguJTQlCBgEO8vi4i4ZtPMR2LEM2KM'
    end

    def formated_old_tweets(tweets)
      return tweets if params[:new_version].to_s == "true"
      {
        "completed_in" => tweets["search_metadata"]["completed_in"],
        "max_id" => tweets["search_metadata"]["max_id"],
        "max_id_str" => tweets["search_metadata"]["max_id_str"],
        "next_page" => tweets["search_metadata"]["next_results"],
        "page" => @page,
        "query" => tweets["search_metadata"]["query"],
        "refresh_url" => tweets["search_metadata"]["refresh_url"],
        "results" => tweets["statuses"].map{|status| {
            "created_at" => status["created_at"],
            "from_user" => status["user"]["name"],
            "from_user_id_str" => status["user"]["id_str"],
            "from_user_name" => status["user"]["screen_name"],
            "from_user_location" => status["user"]["location"],
            "from_user_followers_count" => status["user"]["followers_count"],
            "from_user_statuses_count" => status["user"]["statuses_count"],
            "from_user_friends_count" => status["user"]["friends_count"],
            "geo" => status["geo"],
            "id" => status["id"],
            "id_str" => status["id_str"],
            "iso_language_code" => status["metadata"]["iso_language_code"],
            "metadata" => {
              "result_type" => status["metadata"]["result_type"]
            },
            "profile_image_url" => status["user"]["profile_image_url"],
            "source" => status["source"],
            "text" => status["text"],
            "to_user_id_str" => status["in_reply_to_user_id_str"],
            "retweet_count" => status["retweet_count"],
            "retweeted" => status["retweeted"],
            "place" => status["place"]
          }},
        "results_per_page" => tweets["search_metadata"]["count"],
        "since_id" => tweets["search_metadata"]["since_id"],
        "since_id_str" => tweets["search_metadata"]["since_id_str"]
      }
    end

end
