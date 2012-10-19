class FeedApisController < ApplicationController
  skip_before_filter :require_user, :only => [:index]
  
  def index
	feed_apis = FeedApi.all
	respond_to do |format|
      respond_to_do(format, feed_apis)
	end
  end
  
end
