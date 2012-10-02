class UsersController < ApplicationController
  skip_filter :require_user, :only => [:new, :create, :forgot_password, :profiles, :contact_admin]
  before_filter :prepare_user, :only => [:show, :create, :update]
  caches_action :profiles
  
  # GET /users/:id.json
  def show  
    access_denied unless is_owner?
    @user.create_autopopulate if params[:auto_populate].present?
    get_profiles
    api_responds(@user){ render :partial => "users/info"}
  end

  # POST /users.xml
  # POST /users.json 
  def create
	  params[:user][:login] = params[:user][:email_work] if params[:user][:login].blank?
    user = params[:user]
    @user = User.create(user)
    @user.valid? ? after_save(user) : error_responds(@user)
  end

  # Request: 
  #   - PUT /users/123000000001.json
  #   - PUT /users/123000000001.xml
  # Create Column through User's update:
  #  { user: 
  #     {
  #       _id: "123000000001", 
  #       feed_accounts_attributes: [
  #         {category: "rss", title: "New Rss Column"}
  #       ] 
  #     }
  #  }
  # Update Column through User's update:
  #  { user: 
  #     {
  #       _id: "123000000001", 
  #       feed_accounts_attributes: [
  #         {_id: "456000000001", title: "Changed Title"}
  #       ] 
  #     }
  #  }
  def update
    access_denied unless is_owner?
    params[:user][:login] = params[:user][:email_work] if params[:user][:login].blank?
    user = params[:user]
    @user.is_exist(user[:email_work]) if user[:email_work].present?
    is_updatable?(user) ? after_save(user) : error_responds(@user)
  end
  
  def generate_population
    start_autopopulate if current_user
  end

  def forgot_password
    @user = User.forgot_password(params[:email])
    @user.errors.count < 1 ?  api_responds(@user) : error_responds(@user)
  end

  def profiles
     @categories = ProfileCategory.all
     api_responds(@categories)
  end

  def contact_admin
    #status = "SPAM"
    #if !Akismetor.spam?(akismet_attributes(params[:form]))
    #  Resque.enqueue(Finfores::Backgrounds::EmailAlert,"contact_admin", params[:form].to_yaml)     
      status = "SUCCESS"     
      UserMailer.user_speak(params[:form]).deliver
    #end
    respond_to do |format|
	    format.html {render :text => status}
	    format.json {render :json => {:status => "SUCCESS"}}
	    format.xml  {render :xml => {:status => "SUCCESS"}}
	  end
  end

  private

    def akismet_attributes(options)
  	 {
  	    :key                  => '00864d8d758f',
  	    :blog                 => 'http://finfore.net',
  	    :user_ip              => request.remote_ip,
  	    :user_agent           => request.env['HTTP_USER_AGENT'],
  	    :comment_author       => options[:name],
  	    :comment_author_email => options[:email],
  	    :comment_author_url   => '',
  	    :comment_content      => options[:message]
  	  }
    end
    
    def prepare_user
	    opts = {:feed_accounts => {:includes => {:user_feeds => :feed_info}}}, {:user_company_tabs => {:includes => {:feed_info => :company_competitor}}}
      @user = User.includes(opts).where(:_id => params[:id]).first
    end
    
    def is_owner?
      return false if !current_user && !@user
      @user.login === current_user.login
    end
    
    def access_denied
      error_responds(error_object("Access denied"))
    end
    
    def after_save(user)
	    @user.check_profiles(user[:profile_ids]) if user[:profile_ids].present?
      #@user.create_autopopulate if params[:auto_populate].present?
      @user.create_autopopulate if @user.is_populateable? && @user.valid?
      UserMailer.welcome_email(@user, user[:password]).deliver unless user[:password].blank?
      get_profiles
      api_responds(@user)
    end
    
    def is_updatable?(user)
      @user.errors.size < 1 && @user.update_attributes(user)
    end
    
    def get_profiles
	    @profiles = Profile.where({:_id.in => @user.user_profiles.map(&:profile_id)})
	  end
end
