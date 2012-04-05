class UserSessionsController < ApplicationController
  include Finforenet::Controllers::SocialNetwork
  
  skip_before_filter :require_user,         :except => [:destroy]
  before_filter      :destroy_user_session, :only   => [:create]
  
  
  def create
    @user_session = UserSession.new(credential_information)
    @user_session.save ? on_login_success : error_responds(error_object(ERR_LOGIN))
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
	
	      user = User.by_username(profile['username'])
        access_token_attr = access_token_object(profile, access_token)

        if user.blank?
          password = random_characters
	        user_email = random_characters + "@#{access_token_attr[:category]}.com"
	        user_email = access_token_attr[:username] if profile['username'].match(REGEX_EMAIL)
	        user_objects = {:full_name   			         => profile['name'], 
					            	  :email_work  			         => user_email,
						              :login       			         => user_email,
						              :password    			         => password,
						              :password_confirmation     => password,
		                      :access_tokens_attributes  => [access_token_attr],
		                      :feed_accounts_attributes => prepared_feed_accounts_attributes(access_token_attr)
		                     }
          user = User.create(user_objects)
				else
				  user_access_token = user.access_tokens.first
				  user_access_token.update_attributes(access_token_attr)
				  accounts = user.feed_accounts.includes(:feed_token).where("feed_token.username" => user_access_token.username)
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

    respond_to do |format|
      if user.blank?
        accident_alert("Your session is terminated, please go back to your refference url (#{request.env['HTTP_REFERER']})")
      elsif stored_data[:callback].blank?
        respond_to_do(format, user)
      else
		    param_auth = "auth_token=#{user.single_access_token}&auth_secret=#{user.persistence_token}&user_id=#{user.id}"
		    param_auth = param_auth + (user.user_profiles.length < 1 ? "&update_profile=true" : "&update_profile=false")
		    redirect_uri = stored_data[:callback] + ((stored_data[:callback].scan(/\?/i).size > 0) ? "&" : "?") + param_auth
		    format.html {redirect_to redirect_uri}
      end
    end
  end

  def public_login
    pids =  params[:pids].gsub(/\,$|^\,|\s/i,"").split(",")
    @user_session = nil
    public_login = PublicLogin.where(:profile_ids => pids.join(",")).first
    unless public_login
      result = User.find_public_profile(pids)
      if result[:user].present?
        PublicLogin.create({:user_id => result[:user].id, :profile_ids => result[:selecteds] || pids.join(",")})
      end
    else
	    result = {:user => public_login.user, :selecteds => public_login.profile_ids.split(",")}
	  end
    
    if result[:user].present?
     destroy_user_session
     
     @user_session = UserSession.new(result[:user])
     @user_session.save
     @user_session.record.selected_profiles = result[:user].selected_profiles
     result[:user] = @user_session.record
     if result[:selecteds].present?
	     result[:selecteds] = Profile.where(:_id.in => result[:selecteds]).to_a
	   elsif result[:user].present?
	     result[:selecteds] = Profile.where(:_id.in => pids).to_a
	   end
	   @selecteds = result[:selecteds]
	   @user = result[:user]
	   @profiles = Profile.where({:_id.in => @user.user_profiles.map(&:profile_id)})
	   api_responds(result)
    else
	    error_responds({:error=>"NotFound"})
	  end
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
      return {:category => profile['provider'], :username => profile['username'], :token => token, :secret => secret}
    end
	
	def column_attribute(feed_token_attr,category)
	  {:category              => category,
       :window_type           => "tab",
	   :name                  => category,
	   :feed_token_attributes => feed_token_attr}
	end
	
	def prepared_feed_accounts_attributes(token_attr)
	  attributes = []
	  feed_token_attr = {:token => token_attr[:token], :secret => token_attr[:secret], :username => token_attr[:username]}
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
      @user = User.where(:login=>@user_session.record.login).first
      api_responds(@user)
    end
end