# Parameters:
# Create Column directly:
# POST /feed_accounts.json
#   * feed_account = {category: "rss", title: "New Rss Column"}
#
# Update Column directly:
# PUT /feed_accounts/789000001.json
#   * feed_account = {category: "rss", title: "Changed Title"}
#
# Delete Column directly:
# DELETE /feed_accounts/789000001.json

class FeedAccountsController < ApplicationController
  include Finforenet::Controllers::SocialNetwork
  skip_before_filter :require_user,     :only => [:column_callback]
  before_filter      :prepare_callback, :only => [:column_auth]

  def index
	  @columns = FeedAccount.owned_by({:user_id => current_user.id})
	  api_responds(@columns)
  end
  
  def show
	  @column = current_user.show_column(params[:id])
	  api_responds(@column)
  end
  
  def create
	  if params[:user]
	  	current_user.update_attributes(params[:user])
	  	result = current_user
	  	@column = current_user.feed_accounts if result.valid?
	  else
	  	result = @column = FeedAccount.create(params[:feed_account].merge!({:user_id => current_user.id}))
	  end
	  error_responds(result) unless result.valid?
	  api_responds(@column) if result.valid?
	end

  def update
    @column = current_user.show_column(params[:id])
  	@column.update_attributes(params[:feed_account]) if @column
    @column.valid? ? api_responds(@column) : error_responds(@error)
  end

  def destroy
  	@column = current_user.show_column(params[:id])
  	@column.destroy if @column
    api_responds(@column) 
  end

  def column_auth
    params[:format] = "html"
    respond_to do |format|
      format.html {redirect_to authorize_url}
    end
  end

  def column_callback
    @cat = params[:cat]
    if @cat.present? && session[@cat].present?
      @stored_data = session[@cat]
      user = User.where(:single_access_token => params[:finfore_token]).first unless params[:finfore_token].blank?
      access_token = get_network_access
      feed_account = create_column_and_token(access_token, @api, user)
      param_auth = "auth_token=#{user.single_access_token}" + (feed_account.blank? ? "" : "&feed_account_id=#{feed_account.id}&feed_token_id=#{feed_account.feed_token.id}")
      redirect_custom = @stored_data[:callback] + ((@stored_data[:callback].scan(/\?/i).size > 0) ? "&" : "?") + param_auth
    end

     if @stored_data.present?
       params[:format] = 'json' if @stored_data[:callback].blank?
       respond_to do |format|
		     if @stored_data[:callback].blank?
		       respond_to_do(format, feed_account)
		     else
			     format.html {redirect_to redirect_custom}
		     end
       end
     else
       accident_alert("SessionNotFound")
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

    def create_column_and_token(access_token, api, user)
      profile = OauthMedia.profile_network(access_token,api.category)

      if @stored_data[:category].match(/google/) && @stored_data[:column_id].blank?
        categories = ["gmail","portfolio"]
      elsif !@stored_data[:column_id].blank?
        column = user.feed_accounts.find(@stored_data[:column_id])
        categories = [column.category]
      else
        categories = [@stored_data[:category]]
      end


      categories.each do |category|
        column_data = {}
				token_data = {:token  => (category.match(/facebook/i) ? access_token.access_token : access_token.token),
                      :secret => (category.match(/facebook/i) ? '' : access_token.secret),
				              :username    => (category != "linkedin" ? profile['username'] : profile['name'])}
		
        if @stored_data[:column_id].blank?
          column_data = {:name                  => (category != "linkedin" ? profile['username'] : profile['name']),
				                 :window_type           => 'tab', 
				                 :category              => category,
				                 :feed_token_attributes => token_data}
			    column = user.feed_accounts.create(column_data)
				elsif column
				  if column.feed_token.blank?
			       column.update_attributes({:feed_token_attributes => token_data})
				  else
						column.feed_token.update_attributes(token_data)
				  end
				end  
      end
	    return column
	  end
end
