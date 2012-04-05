class UserFeedsController < ApplicationController
  
  
  def update
    @user_feed = UserFeed.where({:_id => params[:id], :feed_account_id => params[:feed_account_id]}).first
	  @user_feed.update_attributes(params[:user_feed]) ? api_responds(@user_feed) : error_responds(@user_feed) 
  end
  
  
  def destroy
	  @user_feed = UserFeed.where({:_id => params[:id], :feed_account_id => params[:feed_account_id]}).first
	  @user_feed.destroy
	  api_responds(@user_feed)
  end
  
end
