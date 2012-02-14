class UsersController < ApplicationController
  skip_filter :require_user, :only => [:new, :create, :forgot_password, :profiles]
  #caches_action :profiles, :expires_in => 4.hours

  # GET /users/:id.json
  def show  
    @user = User.find(params[:id])
    respond_to do |format|
      if @user && @user.login == current_user.login
		user.create_autopopulate unless params[:auto_populate].blank?
        respond_to_do(format, @user)
      else
		supported_formats(format, error_object("You are not the owner of this account")) 
      end
    end
  end

  # POST /users.xml
  # POST /users.json 
  def create
    unless params[:auto_populate].blank?
      params[:user][:email_home] = params[:user][:email_work]
      params[:user][:password_confirmation] = params[:user][:password] = random_characters
    else
      primary_email = params[:user][:is_email_home] ? params[:user][:email_home] : params[:user][:email_work]
      params[:user][:login] = primary_email
    end
    
    @user = User.create(params[:user])     
    
    respond_to do |format|
      if @user.errors.empty?
        @user.create_autopopulate unless params[:auto_populate].blank?
        UserMailer.welcome_email(@user, params[:user][:password]).deliver
        respond_to_do(format, @user)
      else
        respond_error_to_do(format, @user)
      end
    end
  end

  # PUT /users/1.xml
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
    is_owner = @user.login == current_user.login ? true : false     
    is_new = @user.feed_accounts.count < 1 && !params[:user][:password].blank?
    
    unless params[:user][:email_work].blank?
      @user.is_exist(params[:user][:email_work])
    end if is_new
    
    respond_to do |format|
      if !is_owner
		supported_formats(format, error_object("You are not the owner of this account")) 
      elsif @user.errors.size < 1 && @user.update_attributes(params[:user])
        @user.create_autopopulate unless params[:auto_populate].blank?
        UserMailer.welcome_email(@user, params[:user][:password]).deliver if is_new
        respond_to_do(format, @user)
      else
        respond_error_to_do(format, @user)
      end
    end
  end
  
  def generate_population
    start_autopopulate if current_user
  end

  def forgot_password
    is_success = false
    new_password = random_characters
    user = User.where("$or" => [{:email_work => params[:email]}, {:email_home => params[:email]}, {:login => params[:email]}]).first
    if user
      user.update_attribute(:password,new_password)
      is_success = true
    end
    status = "FAILED"
    
    respond_to do |format|
      if is_success
		UserMailer.forgot_password(user,new_password).deliver
        status = "SUCCESS"
      end
      respond_to_do(format, {:status => status})
    end
  end

  def profiles
     categories = ProfileCategory.includes(:profiles).where({"profiles.is_private" => {"$ne" => true}})
     respond_to do |format|
        respond_to_do(format, categories)
     end
  end

  def contact_admin
    status = "SPAM"
    if !Akismetor.spam?(akismet_attributes(params[:form]))
      Resque.enqueue(Finfores::Backgrounds::EmailAlert,"contact_admin", params[:form].to_yaml)     
      status = "SUCCESS"     
      UserMailer.contact_us(params[:form][:to], params[:form][:subject], params[:form]).deliver
    end
    respond_to do |format|
      respond_to_do(format,{:status => status})
    end
  end

  private

    def akismet_attributes options
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
    
end
