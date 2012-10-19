class FacebookersController < ApplicationController
  before_filter :prepare_feed_token

   def my
     api_responds(FGraph.me(params[:category],@fb_opts))
     rescue => e
       respond_rescue(e)
   end
   
   def publish
     @fb_opts.merge!(publish_opts) unless params[:option].blank?
     api_responds(FGraph.publish(publish_path, @fb_opts))
     rescue => e
       respond_rescue(e)
   end

   def search
     @fb_opts.merge!(:type => params[:type]) and fb_pagination
     api_responds(FGraph.search(params[:keyword], @fb_opts))
     rescue => e
       respond_rescue(e)
   end


  private
    def respond_rescue(e)
      respond_to do |format|
        format.json { render :json => e.to_json,:status => 200 }
      end
    end
    
    def publish_path
      params[:pid]+"/"+params[:pubtype]
    end
    
    def fb_pagination
      @fb_opts.merge!(:limit => params[:limit]) unless params[:limit].blank?
      @fb_opts.merge!(:offset => params[:offset]) unless params[:offset].blank?
    end
    
    def publish_opts
      {params[:option].to_sym => params[:option_value]}
    end

    def prepare_feed_token
      api = FeedApi.auth_by('facebook')
      if params[:feed_account_id]
        feed_account = current_user.feed_accounts.find(params[:feed_account_id])
        @feed_token = feed_account.feed_token
        @fb_opts = {:access_token=>@feed_token.token}
      end
      
      rescue => e
       respond_rescue(e)
    end

end
