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
    tweets = @tweetfore ? @tweetfore.search(params) : error_object("Invalid Token or Reference")
    respond_to do |format|
      respond_to_do(format,tweets)
    end
    rescue => e
     respond_rescue(e)
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
        format.json { render :json => e.to_json,:status => 200 }
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
      #if params[:feed_account_id]
        user = User.where(:login => current_user.login).first
        feed_account = user.feed_accounts.find(params[:feed_account_id])
        #params[:feed_token_id] = feed_account.feed_token.id
		@feed_token = feed_account.feed_token
      #end
      #@feed_token = FeedToken.where(params[:feed_token_id],current_user.id)
      @tweetfore = TwitterOAuth::Client.new(
                    :consumer_key => @twitter_api,
                    :consumer_secret => @twitter_secret,
                    :token => @feed_token.token,
                    :secret => @feed_token.secret
                ) if @feed_token
      params.delete(:feed_token_id)
      params.delete(:feed_account_id)
      #rescue => e
      # respond_rescue(e)
    end

    def make_api
      @linkedin_api = 't_4wFj-MqkExvbTSoRGButHzVA44kwnsaJnswD63RCHeWet7B4N9REyo6pMtztA5'
      @linkedin_secret = 'TPHkKZdW_Wt1Mc_TScbj9e5eSzHHs62ERCDB1kVTKXlQwivapUaOP0Tw_1NcGOq9'
      @twitter_api = 'RhXx78t99jxXAf44NwY4w'
      @twitter_secret = 'ty0AhbgCaDQULguJTQlCBgEO8vi4i4ZtPMR2LEM2KM'
    end

end
