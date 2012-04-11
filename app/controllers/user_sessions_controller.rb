class UserSessionsController < ApplicationController
  include Finforenet::Controllers::SocialNetwork
  
  skip_before_filter :require_user,         :except => [:destroy]
  before_filter      :destroy_user_session, :only   => [:create]
  #before_filter      :prepare_network_sigin, :only   => [:network_sign_in]
  
  def create
    @user_session = UserSession.new(credential_information)
    respond_to do |format|
      if @user_session.save
        on_login_success(format)
      else
		supported_formats(format, error_object(ERR_LOGIN), :unprocessable_entity)        
      end
    end
  end

  def destroy
    user = current_user
    unless params[:column_ids].blank?
      user = User.find user.id
      user.update_attributes({:remember_columns => params[:column_ids], :is_online => false}) 
    end
    destroy_user_session
    
    respond_to do |format|
      respond_to_do(format, {:text => "success"})
    end
  end

  def network_sign_in
	session['social_login'] ||= {}
	auth_url = prepared_authorize_url
    
    params[:format] = "html"
    
    respond_to do |format|
      if auth_url.blank?
        format.html {render :text=> get_failed_message}
      else
        format.html {redirect_to auth_url}
      end
    end

    rescue => e
      accident_alert(e.to_s)
  end

  def create_network
    social_login = session['social_login']
    @cat = params[:cat]
    includes = []
    destroy_user_session
    
    if !@cat.blank? && !social_login.blank?
      stored_data = social_login[@cat]
      if !stored_data.blank?
        api = FeedApi.auth_by(stored_data[:category])

        unless api.isFacebook?
          request_token = OAuth::RequestToken.new(get_consumer(api),stored_data[:rt],stored_data[:rs])
          access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
        else
          get_callback_login
          access_token = FGraph.oauth_access_token(api.api, api.secret, :code=>params[:code], :redirect_uri => @callback_url)
          access_token = OpenStruct.new access_token
        end

        profile = get_profile_network(access_token,api,stored_data)
	
	    user = User.by_uid(profile['uid'])
        access_token_attr = access_token_object(profile, access_token)

        if user.blank?
          password = random_characters
	      user_email = random_characters + "@#{access_token_attr[:category]}.com"
	      user_email = access_token_attr[:uid] if profile['uid'].match(REGEX_EMAIL)
	      user_objects = {:full_name   			         => profile['name'], 
						  :email_work  			         => user_email,
						  :login       			         => user_email,
						  :password    			         => password,
						  :password_confirmation         => password,
		                  :access_tokens_attributes      => [access_token_attr],
		                  :feed_accounts_attributes => prepared_feed_accounts_attributes(access_token_attr)
		                 }
          user = User.create(user_objects)
		else
		  user_access_token = user.access_tokens.first
		  user_access_token.update_attributes(access_token_attr)
		  accounts = user.feed_accounts.includes(:feed_token).where("feed_token.uid" => user_access_token.uid)
		  accounts.each do |account|
			account.feed_token.update_attributes({:token          => access_token.token, 
			                                      :secret         => access_token.secret, 
			                                      :token_preauth  => "", 
			                                      :secret_preauth => "", 
			                                      :url_oauth      => ""})
		  end
		  if accounts.count < 1
			user.update_attributes({:user_feed_accounts_attributes => prepared_feed_accounts_attributes(access_token_attr)})
		  end
        end
	
        session['social_login'].delete(@cat) if user && session['social_login']
        current_user
      end
    end
logger.debug "*********"
logger.debug user
if user.present?
logger.debug user.errors.full_messages
end

    respond_to do |format|
      if user.blank?
        accident_alert("Your session is terminated, please go back to your refference url (#{request.env['HTTP_REFERER']})")
      else
		if stored_data[:callback].blank?
          respond_to_do(format, user)
        else
		  param_auth = "auth_token=#{user.single_access_token}&auth_secret=#{user.persistence_token}&user_id=#{user.id}"
		  param_auth = param_auth + (user.profiles.length < 1 ? "&update_profile=true" : "&update_profile=false")
		  redirect_uri = stored_data[:callback] + ((stored_data[:callback].scan(/\?/i).size > 0) ? "&" : "?") + param_auth
logger.debug redirect_uri
logger.debug "*********"
		  format.html {redirect_to redirect_uri}
        end
      end
    end
  end

  def public_login
    pids =  params[:pids].gsub(/\,$|^\,|\s/i,"").split(",")
    @user_session = nil
    result = User.find_public_profile(pids)
    
    if result[:user].present?
     destroy_user_session
     @user_session = UserSession.new(result[:user])
     @user_session.save
     @user_session.record.selected_profiles = result[:user].selected_profiles
     result[:user] = @user_session.record
    end
    if result[:selecteds].present?
      result[:selecteds] = Profile.where(:_id.in => result[:selecteds])
    end
    respond_to do |format|
      if @user_session.blank? && result[:user].blank?
        respond_to_do(format, {:message=>"NotFound"})
      else
        respond_to_do(format, result)
      end
    end

    #rescue => e
    #  accident_alert(e.to_s)
  end

  def failure_network
    params[:message] ||= ERR_LOGIN
    respond_to do |format|
      supported_formats(format, error_object(params[:message]), :unprocessable_entity)
    end
  end

  def destroy
    @authorization = current_user.authorizations.find(params[:id])
    @authorization.destroy
    respond_to do |format|
      supported_formats(format, {:text => "logout"})
    end
  end

  private

    def access_token_object(profile, access_token)
      token  = profile['provider'] != "facebook" ? access_token.token : access_token.access_token
      secret = profile['provider'] != "facebook" ? access_token.secret : ''
      return {:category => profile['provider'], :uid => profile['uid'], :token => token, :secret => secret}
    end
	
	def column_attribute(feed_token_attr,category)
	  {:category              => category,
       :window_type           => "tab",
	   :name                  => category,
	   :feed_token_attributes => feed_token_attr}
	end
	
	def prepared_feed_accounts_attributes(token_attr)
	  attributes = []
	  feed_token_attr = {:token => token_attr[:token], :secret => token_attr[:secret], :uid => token_attr[:uid]}
	  categories = token_attr[:category].match(/google/i) ? ["gmail","portfolio"] : [token_attr[:category]]
	  categories.each do |category|
		attributes.push( column_attribute(feed_token_attr, category) )
	  end
	  return attributes
	end

    def destroy_user_session
      current_user_session.destroy unless current_user_session.blank?
      reset_session
    end

    def credential_information
      params[:user_session] = {:login => params[:login], :password => params[:password]} if params[:user_session].blank?
      return params[:user_session]
    end

    def on_login_success(format)
      user = User.where(:login=>@user_session.record.login).first
      respond_to_do(format, user)
    end
end
