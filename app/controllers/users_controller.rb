class UsersController < ApplicationController
  skip_filter :require_user, :only => [:new, :create, :forgot_password, :profiles]
  before_filter :prepare_user, :only => [:show, :create, :update]
  
  # GET /users/:id.json
  def show  
    access_denied unless is_owner?
    @user.create_autopopulate if params[:auto_populate].present?
    api_responds(@user)
  end

  # POST /users.xml
  # POST /users.json 
  def create
    user = params[:user]
    user[:password_confirmation] = user[:password] = random_characters if user.present?
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
    user = params[:user]    
    is_new = @user.feed_accounts.count < 1 && !user[:password].blank?
    @user.is_exist(user[:email_work]) if user[:email_work].present? && is_new
    is_updatable?(user) ? after_save(user, is_new) : error_responds(@user)
  end
  
  def generate_population
    start_autopopulate if current_user
  end

  def forgot_password
    @user = User.forgot_password(params[:email], random_characters)
    @user.errors.count < 1 ?  api_responds(@user) : error_responds(@user)
  end

  def profiles
     categories = ProfileCategory.with_public_profiles
     api_responds(categories)
  end

  def contact_admin
    status = "SPAM"
    if !Akismetor.spam?(akismet_attributes(params[:form]))
      Resque.enqueue(Finfores::Backgrounds::EmailAlert,"contact_admin", params[:form].to_yaml)     
      status = "SUCCESS"     
      UserMailer.contact_us(params[:form][:to], params[:form][:subject], params[:form]).deliver
    end
    api_responds({:status => status})
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
      @user = User.includes([:feed_accounts]).where(:_id => params[:id]).first
    end
    
    def is_owner?
      return false if !current_user && !@user
      @user.login === current_user.login
    end
    
    def access_denied
      error_responds(error_object("Access denied"))
    end
    
    def after_save(user, is_new = true)
	    @user.check_profiles(user[:profile_ids]) if user[:profile_ids].present?
      @user.create_autopopulate if params[:auto_populate].present?
      UserMailer.welcome_email(@user, user[:password]).deliver if is_new
      api_responds(@user)
    end
    
    def is_updatable?(user)
      @user.errors.size < 1 && @user.update_attributes(user)
    end
end
