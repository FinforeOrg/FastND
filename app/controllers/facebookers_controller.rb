class FacebookersController < ApplicationController
  before_filter :prepare_feed_token

   def my
     result = FGraph.me(params[:category],:access_token=>@feed_token.token)

     respond_to do |format|
      respond_to_do(format,result)
     end
     rescue => e
       respond_rescue(e)
   end
   
   def publish
     options = {:access_token=>@feed_token.token}
     options[params[:option].to_sym] = params[:option_value] unless params[:option].blank?
     result = FGraph.publish(params[:pid]+"/"+params[:pubtype], options)

     respond_to do |format|
      respond_to_do(format,result)
     end
     rescue => e
       respond_rescue(e)
   end

   def search
     options = {:access_token=>@feed_token.token,:type=>params[:type]}
     options[:limit] = params[:limit] unless params[:limit].blank?
     options[:offset] = params[:offset] unless params[:offset].blank?
     
     result = FGraph.search(params[:keyword],options)
     
     respond_to do |format|
      respond_to_do(format,result)
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
      api = FeedApi.auth_by('facebook')
      user = User.where(:login => current_user.login).first
      if params[:feed_account_id]
        feed_account = user.feed_accounts.find(params[:feed_account_id])
        @feed_token = feed_account.feed_token
      end
      
      rescue => e
       respond_rescue(e)
    end

end
