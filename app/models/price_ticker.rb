class PriceTicker
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :version_field  => :version,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true
                  
  field :ticker, :type => String
  field :position, :type => Integer
  index :ticker
  index :position

  default_scope asc(:position)
  
  belongs_to :feed_info, :index => true
end
