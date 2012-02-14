class FeedAccountsController < ApplicationController
  include Finforenet::Controllers::SocialNetwork
  skip_before_filter :require_user, :only => [:column_callback]

  def index
    respond_to do |format|
       respond_to_do(format, current_user.feed_accounts)
    end
  end
  
  def show
	feed_account = current_user.feed_accounts.find(params[:id])
	respond_to do |format|
       respond_to_do(format, feed_account)
    end
  end

  def column_auth
    auth_url = prepared_authorize_url

    params[:format] = "html"

    respond_to do |format|
      if auth_url.blank?
        respond_to_do(format, {:message => get_failed_message})
      else
        format.html {redirect_to auth_url}
      end
    end

    #rescue => e
    #  accident_alert(e.to_s)
  end

  def column_callback
    feed_account = {}
    @cat = params[:cat]

    if !@cat.blank? && !session[@cat].blank?
      stored_data = session[@cat]
      user = User.where(:single_access_token => params[:finfore_token]).first unless params[:finfore_token].blank?
      api = FeedApi.auth_by(stored_data[:category])

      unless api.isFacebook?
        request_token = OAuth::RequestToken.new(get_consumer(api),stored_data[:rt],stored_data[:rs])
        access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
      else
        get_callback_column
        access_token = FGraph.oauth_access_token(api.api, api.secret, {:code=>params[:code],:redirect_uri=>@callback_url})
        access_token = OpenStruct.new access_token
      end
      feed_account = create_column_and_token(access_token, api, stored_data,user)
    end

     if !stored_data.blank?
       params[:format] = 'json' if stored_data[:callback].blank?
       respond_to do |format|
		 if stored_data[:callback].blank?
		   respond_to_do(format, feed_account)
		 else
			param_auth = "auth_token=#{user.single_access_token}" + (feed_account.blank? ? "" : "&feed_account_id=#{feed_account.id}&feed_token_id=#{feed_account.feed_token.id}")
			redirect_custom = stored_data[:callback] + ((stored_data[:callback].scan(/\?/i).size > 0) ? "&" : "?") + param_auth
			format.html {redirect_to redirect_custom}
		  end
       end
     else
       accident_alert("SessionNotFound")
     end
  end
  
  def create
	if params[:user]
	  columns = current_user.update_attributes(params[:user])
	else
	  columns = current_user.feed_accounts.create(params[:feed_account])
	end
	
    respond_to do |format|
	  column_respond(format,columns)
    end
  end

  def update
	column = current_user.feed_accounts.find(params[:id])
    column.update_attributes(params[:feed_account]) if column

    respond_to do |format|
      column_respond(format,column)
    end
  end

  def destroy
    column = current_user.feed_accounts.where(:_id => params[:id]).first
    column.destroy if column

    respond_to do |format|
      column_respond(format,column)
    end
  end

  private
  
    def column_respond(format,columns)
	  column = columns.class.equal?(Array) ? columns.last : columns
	  if column && column.errors.size < 1
        respond_to_do(format,columns)
      else
        respond_error_to_do(format, column)
      end
	end

    def create_column_and_token(access_token, api, stored_data, user)
      profile = get_profile_network(access_token,api,stored_data)

      if stored_data[:category].match(/google/) && stored_data[:column_id].blank?
        categories = ["gmail","portfolio"]
      elsif !stored_data[:column_id].blank?
        column = user.feed_accounts.find(stored_data[:column_id])
        categories = [column.category]
      else
        categories = [stored_data[:category]]
      end


      categories.each do |category|
        column_data = {}
		token_data = {:token  => (category.match(/facebook/i) ? access_token.access_token : access_token.token),
                      :secret => (category.match(/facebook/i) ? '' : access_token.secret),
		              :uid    => (category != "linkedin" ? profile['uid'] : profile['name'])}
		
        if stored_data[:column_id].blank?
          column_data = {:name                  => (category != "linkedin" ? profile['uid'] : profile['name']),
		                 :window_type           => 'tab', 
		                 :category              => category,
		                 :feed_token_attributes => token_data}
	      column = user.feed_accounts.create(column_data)
		  #user.save
		elsif column
		  if column.feed_token.blank?
		    #column.feed_token = FeedToken.new(token_data)
                    column.update_attributes({:feed_token_attributes => token_data})
		  else
			column.feed_token.update_attributes(token_data)
		  end
		end  
      end
      #column.save
	  return column
	end
end
