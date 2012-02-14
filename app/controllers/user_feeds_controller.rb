class UserFeedsController < ApplicationController
  
  
  def update
    feed_account = current_user.feed_accounts.find(params[:feed_account_id])
	user_feed = feed_account.user_feeds.find(params[:id])

    respond_to do |format|
      if user_feed.update_attributes(params[:user_feed])
        flash[:notice] = 'user_feed was successfully updated.'
        respond_to_do(format, user_feed)
      else
        respond_error_to_do(format, user_feed)
      end
    end
  end
  
  
  def destroy
	feed_account = current_user.feed_accounts.find(params[:feed_account_id])
	user_feed = feed_account.user_feeds.find(params[:id])
	user_feed.destroy

    #Resque.enqueue(Finfores::Backgrounds::TwitterUtils,'unfollow', @user_feed.feed_account.id, [@user_feed.name].to_yaml)
    #Finfores::Jobs::TwitterWorker.new('unfollow', @user_feed.feed_account.id, [@user_feed.name].to_yaml)

    respond_to do |format|
      respond_to_do(format, user_feed)
    end
  end
  
end
