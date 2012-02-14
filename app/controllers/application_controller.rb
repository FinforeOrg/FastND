class ApplicationController < ActionController::Base
  #before_filter :set_access_control_headers
  before_filter :require_user

  include Finforenet::Controllers::Filterable
  include Finforenet::Controllers::Responder

  protect_from_forgery
  helper :all
  helper_method :current_user_session, :current_user

  private 

    def options
      render :text => "here is text"
    end
  
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      unless params[:auth_token].blank?
		user = User.auth_by_security(params[:auth_token],params[:auth_session]) if params[:auth_secret].blank?
		user = User.auth_by_persistence(params[:auth_token],params[:auth_secret]) if !params[:auth_secret].blank?
		
		if user
		  @current_user_session = UserSession.new(user)
		  @current_user_session.save
		end
      else
		@current_user_session = UserSession.find
      end
      
      #rescue => e
	  #@current_user_session
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def require_user
      accident_alert(ERR_AUTH) if !current_user
    end
  
    def require_no_user
      if current_user
		accident_alert(error_object("You must be logged out to access this request"))
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end
    
    def start_autopopulate
	  @user = current_user if @user.blank?
	  @user.create_autopopulate
    end

    def set_access_control_headers
      headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN']
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      #headers['Status'] = '200'
      headers['Access-Control-Max-Age'] = '1000'    
      headers['Access-Control-Allow-Headers'] = '*,x-requested-with'
    end
  
end
