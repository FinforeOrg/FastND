class LinkedinsController < ApplicationController
  require 'linkedin'
  require 'yajl'
  require 'xmlsimple'
  require 'net/http'
  skip_before_filter :require_user
  

  def authenticate
    if @user_token
      session[:atoken] = @user_token.token
      session[:asecret] = @user_token.secret
      xml_auth_url = <<-EOF
                      <clients>
                         <url> #{@user_token.token} </url>
                         <atoken> #{@user_token.token} </atoken>
                         <asecret> #{@user_token.secret} </asecret>
                       </clients>
                     EOF
    else 
      params[:callback] =  "http://#{request.host_with_port}/linkedins/callback" if params[:callback].blank? 
      client = LinkedIn::Client.new(@linkedin_api, @linkedin_secret)
      request_token = client.request_token(:oauth_callback => params[:callback])
      session[:rtoken_linkedin] = request_token.token
      session[:rsecret_linkedin] = request_token.secret
      #LinkedinToken.create({:user_id => current_user.id, :token => request_token.token, :secret => request_token.secret})

      xml_auth_url = <<-EOF
                       <clients>
                         <url>#{client.request_token.authorize_url}</url>
                         <rtoken>#{rtoken_linkedin}</rtoken>
                         <rsecret>#{rsecret_linkedin}</rsecret>
                       </clients>
                     EOF

     end
    
    respond_to do |format|
      format.html {render :text => client.request_token.authorize_url}
      format.xml {render :xml => xml_auth_url}
      format.fxml {render :fxml => xml_auth_url}
    end

  end

  def callback
#    if !params[:oauth_verifier].blank?
#      @client = LinkedIn::Client.new(@linkedin_api, @linkedin_secret)
#      atoken, asecret = @client.authorize_from_request(session[:rtoken_linkedin], session[:rsecret_linkedin], params[:oauth_verifier])
#      if @user_token
#        @user_token.update_attributes({:token => atoken,:secret=>asecret})
#      else
#        LinkedinToken.create({:user_id => current_user.id, :token => atoken, :secret => asecret})
#      end
#      session[:atoken] = atoken
#      session[:asecret] = asecret
#    elsif @user_token && params[:oauth_verifier].blank?
#      session[:atoken] = @user_token.token
#      session[:asecret] = @user_token.secret
#    end
    
    respond_to do |format|
        format.html #{:layout => false}
        format.xml  { render :text => "linkedin"}
        format.fxml { render :text => "linkedin"}
    end
  end

  def network_status
    if params[:tid]
      feed_account = current_user.feed_accounts.where(:category => /linkedin/i).select{|fa| fa.feed_token.id.to_s == params[:tid] }.first
      #feed_account = current_user.feed_accounts.includes(:feed_token).where("feed_tokens._id" => params[:tid]).first
      @linkedin_token = feed_account.feed_token if feed_account
    else
      linkedin = current_user.feed_accounts.where(:category => /linkedin/i).first
      @linkedin_token = linkedin.feed_token if linkedin
    end

    @linkedin_api = FeedApi.auth_by('linkedin')
    if @linkedin_token.token.blank? || @linkedin_token.secret.blank?
      new_results = <<-EOF
                      <network>
                        <updates>empty</updates>
                      </network>
                     EOF
    else
      params[:count] = 20 if params[:count].blank?
      @client = LinkedIn::Client.new(@linkedin_api.api, @linkedin_api.secret)
      @client.authorize_from_access(@linkedin_token.token, @linkedin_token.secret)
      paths = "/people/~/network?type=SHAR&count=#{params[:count]}&start=0"
	parser = Yajl::Parser.new
      results = @client.send("get",paths)
      updates = parser.parse(results)
      new_results = updates["updates"]["values"]
    end
    
    respond_to do |format|
      respond_to_do(format, new_results)
    end
    rescue => e
      respond_to do |format|
        respond_to_do(format, {error: e.to_s})
      end    
  end

  private
  def make_api
    @linkedin_api = 't_4wFj-MqkExvbTSoRGButHzVA44kwnsaJnswD63RCHeWet7B4N9REyo6pMtztA5'
    @linkedin_secret = 'TPHkKZdW_Wt1Mc_TScbj9e5eSzHHs62ERCDB1kVTKXlQwivapUaOP0Tw_1NcGOq9'
  end
    
end
