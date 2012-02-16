module Finforenet
  module Controllers 
    module SocialNetwork
      extend ActiveSupport::Concern
      
      included do
      end

      module InstanceMethods
	
	private
	
	  def prepared_authorize_url
		api = FeedApi.auth_by(params[:provider])
		request_callback = params[:callback]
                #params.delete(:callback)
        
		if api
		  if params[:controller] == "feed_accounts"
		    get_callback_column
			sessionable = session[@cat] = {}
			sessionable.merge!({:column_id => params[:feed_account_id]}) unless  params[:feed_account_id].blank?
		  else
			get_callback_login
			sessionable = session['social_login'][@cat] = {}
		  end
		  sessionable.merge!({:rt => '', :rs => '', :category => api.category, :callback => request_callback})
		  
		  unless api.isFacebook?
			request_token = get_request_token(api)
			login_option = api.category != "google" ? {:force_login => 'false'} : {}
			auth_url = request_token.authorize_url(login_option)
			sessionable.merge!({:rt => request_token.token, :rs => request_token.secret})
		  else
                        perms = "read_friendlists,read_mailbox,read_stream,xmpp_login,manage_notifications,offline_access,publish_stream,email,user_work_history,user_status,user_hometown,user_education_history"
			auth_url = FGraph.oauth_authorize_url(api.api, @callback_url, :scope=> perms)
		  end
		end
		
		return auth_url
	  end
  
	  def get_request_token(api)
	    consumer = get_consumer(api)
	    request_token = consumer.get_request_token({:oauth_callback => @callback_url},more_options(api.category))
	    return request_token
	  end

	  def get_consumer(api)
	    client_options = send(api.category+"_options")
	    consumer = OAuth::Consumer.new(api.api, api.secret, client_options)
	    return consumer
	  end

	  def google_options
	    return { :site               => 'https://www.google.com',
		     :request_token_path => '/accounts/OAuthGetRequestToken',
		     :access_token_path  => '/accounts/OAuthGetAccessToken',
		     :authorize_path     => '/accounts/OAuthAuthorizeToken'
		   }
	  end

	  def twitter_options
	    return {:site => 'https://api.twitter.com', :authorize_path => '/oauth/authorize' }
	  end

	  def linkedin_options
	    return {  :site               => 'https://api.linkedin.com',
		      :request_token_path => '/uas/oauth/requestToken',
		      :access_token_path  => '/uas/oauth/accessToken',
		      :authorize_path     => '/uas/oauth/authorize',
		      :scheme             => :header
		   }
	  end

	  def more_options(category)
	    options = {}
	    if category.scan(/google|gmail/i).size > 0
	      scopes = ["http://www.google.com/m8/feeds/", 
	                "http://finance.google.com/finance/feeds/", 
	                "https://mail.google.com/", 
	                "http://www.google.com/reader/api", 
	                "https://www.google.com/calendar/feeds/", 
	                "http://gdata.youtube.com"]
	      options = {:scope => scopes.join(" ")}
	    end
	    return options
	  end

	  def get_default_callback
	    @cat = random_characters if @cat.blank?
	    url_query = current_user ? "finfore_token=#{current_user.single_access_token}" : "finfore_token=#{params[:finfore_token]||params[:auth_token]}"
	    return "http://#{request.host}/feed_accounts/column_callback?#{url_query}"
	  end
	  
	  def get_callback_login
		@cat = random_characters if @cat.blank?
		@callback_url = "http://#{request.host}/auth/#{params[:provider]}/callback?cat=#{@cat}"
	  end

	  def get_callback_column
	    callback_url = get_default_callback  
	    arbiter = (callback_url.scan(/\?/i).size > 0) ? "&" : "?"
	    @callback_url = callback_url+"#{arbiter}cat=#{@cat}"
            @callback_url = @callback_url+"&format=json" if params[:callback].blank?
	  end

	  def get_failed_message
	    "Sorry - your request does not meet requirements"
	  end

	  def get_profile_network(access_token,api,stored_data)
	    if api.category == "linkedin"
	      person = Nokogiri::XML::Document.parse(access_token.get('/v1/people/~:(id,first-name,last-name)').body).xpath('person')
	      person_hash = {'uid' => person.xpath('id').text, 'provider' => api.category, 'name' => "#{person.xpath('first-name').text} #{person.xpath('last-name').text}"}
	    elsif api.category == "twitter"
	      person = Yajl::Parser.parse(access_token.get('/1/account/verify_credentials.json').body)
	      person_hash = {'uid' => person['screen_name'],'name' => person['name'], 'provider' => api.category}
	    elsif api.category == "facebook"
	      person = FGraph.me(:access_token => access_token.access_token)
	      facebook_email = person.parsed_response['email']
	      facebook_email = person.parsed_response['name'].gsub(/\W/i,"_") + "@" + "facebook.com" if facebook_email.blank?
	      person_hash = {'uid'=>facebook_email, 'name'=>person.parsed_response['name'], 'provider' => api.category}
	    elsif api.category == "google"
	      person = Yajl::Parser.parse(access_token.get("http://www.google.com/m8/feeds/contacts/default/full?max-results=1&alt=json").body)
	      person_hash = google_person_hash(person,api)
	    end
	    return person_hash
	  end

	  def google_person_hash(person,api)
	    email = person['feed']['id']['$t']
	    name = person['feed']['author'].first['name']['$t']
	    name = email if name.strip == '(unknown)'
	    return {'uid' => email, 'provider' => api.category, 'name' => name }
	  end
	
      end
      
      module ClassMethods
	include InstanceMethods
      end
      
    end
  end
end
