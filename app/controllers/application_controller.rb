class ApplicationController < ActionController::Base
  before_filter :require_user

  include Finforenet::Controllers::Filterable
  include Finforenet::Controllers::Responder

  protect_from_forgery
  helper :all
  helper_method :current_user_session, :current_user

  private 
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      begin
        @current_user_session = UserSession.find
      rescue
      end
      if @current_user_session && @current_user_session.record
        if @current_user_session.record.single_access_token == params[:auth_token]
          return @current_user_session
        end
      end
      unless params[:auth_token].blank?
	      user = User.auth_by_token(params)
		    if user
		      @current_user_session = UserSession.new(user)
		      @current_user_session.save
          user.update_history({"current_login_ip" => request.remote_ip, "login_type"=> "token", "user_agent" => request.headers["HTTP_USER_AGENT"], "current_login_at" => Time.now})
          return @current_user_session
		    end
      end
      return nil
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
  
end
