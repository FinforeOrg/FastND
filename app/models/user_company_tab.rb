class UserCompanyTab
  include Mongoid::Document
  include Mongoid::Timestamps
  include Finforenet::Models::SharedQuery
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :version_field  => :version,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
  
  field :follower,     :type => Integer
  field :is_aggregate, :type => Boolean, :default => false
  field :position,     :type => Integer, :default => -1
  
  belongs_to :user
  belongs_to :feed_info, :index => true
  
  delegate :title, :to => :feed_info
  delegate :full_name, :to => :user

  #default_scope asc(:position)
  #before_create :check_position
  
  def check_position
	  self.position = updated_position if self.position < 0
  end
  
end
