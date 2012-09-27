class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Finforenet::Models::ExtUser
   
  field :email_work,            :type => String
  field :login,                 :type => String
  field :full_name,             :type => String
  field :is_online,             :type => Boolean, :default => false
  field :is_public,             :type => Boolean, :default => false
  field :_profile_ids,          :type => Array
  field :has_populated,         :type => Boolean, :default => false

  index :email_work
  index :login
  index :full_name
  
  
  #Association
  has_many :access_tokens,     :dependent => :destroy, :autosave => true
  has_many :feed_accounts,     :dependent => :destroy, :autosave => true, :order => [[ :position, :asc ]]
  has_many :user_company_tabs, :dependent => :destroy, :autosave => true, :order => [[ :position, :asc ]]
  has_many :user_profiles,     :dependent => :destroy, :autosave => true, :class_name => "User::Profile"

  attr_accessor :selected_profiles, :profile_ids
  before_validation :check_login
  accepts_nested_attributes_for :access_tokens, :feed_accounts, :user_company_tabs, :user_profiles

  validates_format_of :email_work, 
                      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, 
                      :message => "is invalid", 
                      :if => :has_email?
  
  def self.forgot_password(_email)
    result = self.where({"$or" => [{:email_work => _email}, {:login => _email}]}).first
    if result.present?
      result.reset_password
      result.save
      UserMailer.forgot_password(result, result.password).deliver
    else
      result = self.new
      result.errors.add(:email, "or login is not found")
    end
    return result
  end
  
  def create_feed_account(opts)
    if opts[:category].blank?
      self.errors.add(:column, "category is required")
    elsif opts[:title].blank?
      self.errors.add(:column, "title is required")
    else
      self.feed_accounts << FeedAccount.new(opts.merge!({:user_id => self.id}))
      self.save
    end
  end
  
  def create_column(account)
	  account = FeedAccount.new(account) if account.class.equal?(Hash)
    self.feed_accounts << account
    self.save
  end
  
  def create_tab(tab)
	  tab = UserCompanyTab.new(tab) if tab.class.equal?(Hash)
    self.user_company_tabs << tab
    self.save
  end
  
  def is_exist(work_email)
    is_exist = User.where(:email_work => work_email).count
    self.errors.add(:email_work, "is already taken.") if is_exist > 0
  end
  
  def has_columns?
    (self.feed_accounts.count > 0)
  end

  def is_populateable?
    # !has_populate_columns? && user_profiles.present? && !has_populated
    user_profiles.present? && !has_populated
  end

  # def has_populate_columns?
  #   self.feed_accounts.where(:category => /company|rss|podcast/i).present?
  # end

  def self.find_by_id(val)
    self.where(:_id => val).first
  end
  
  def self.by_username(access_uid)
    at = AccessToken.where({:username => access_uid}).first
    at ? at.user : nil
  end
  
  def self.auth_by_security(auth_token, auth_session)
    user = self.where({:single_access_token => auth_token, :perishable_token => auth_session}).first
    user = self.where({:single_access_token => auth_token, :is_public => true}).first if user.blank?
    return user
  end
  
  def self.auth_by_token(params)
    if params[:auth_secret].blank?
      self.auth_by_security(params[:auth_token],params[:auth_session])
    else
      self.auth_by_persistence(params[:auth_token],params[:auth_secret])
    end
  end
  
  def self.auth_by_persistence(auth_token, auth_persistence)
    self.where({:single_access_token => auth_token, :persistence_token => auth_persistence}).first
  end
  
  def self.find_public_profile(pids)
    _users = self.where(:is_public => true)
    _return = {}
    _garbage = []
    _remain = []
    _selecteds = []
    _users.each do |_user|
      _remain = pids - _user.user_profiles.map{|up| up.profile_id.to_s}
      if _remain.size < 1
        #_user.profile_ids = pids
        _user.selected_profiles = pids
        _selecteds = pids
        _return = _user
        break
      elsif _remain.size < _user.user_profiles.count 
        if _garbage.size < 1
          _garbage.push({:user => _user,:remain_size => _remain.size}) 
        else
          last_data = _garbage[0]
          if last_data[:remain_size].to_i > _remain.size
            _garbage.shift
            _garbage.push({:user => _user,:remain_size => _remain.size})
          end  
        end
      end
    end  
    if _return.blank? && _garbage.size > 0
      _return = _garbage.shift[:user]
      _selecteds = pids - _remain
      _return.selected_profiles = _selecteds
      #_return.profile_ids = _selecteds
    end
    return {:user => _return, :selecteds => _selecteds}
  end

  def profiles
    Profile.find(self.user_profiles.map(&:profile_ids))
  end
  
  def show_column(column_id)
    self.feed_accounts.where(:_id => column_id).first
  end

  def has_email?
    !self.email_work.blank? && self.access_tokens.size < 1
  end

  def not_social_login?
    !(self.access_tokens.count < 1)
  end
  
  def check_profiles(pids)
    if pids.is_a?(Array) && pids.present?
      self.user_profiles.delete_all if self.user_profiles.count > 0
      pids.each do |pid|
        User::Profile.create({:profile_id => pid, :user_id => self.id})
      end
      self._profile_ids = self.user_profiles.map(&:profile_id)
    end
  end
  
  def check_login
    self.login = self.email_work if self.login.blank?
    self.email_work = self.login if self.email_work.blank?
  end

end
