class ProfileCategory
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  track_history   :on => [:all],
                  :modifier_field => :modifier,
                  :version_field  => :version,
                  :track_create   =>  true,
                  :track_update   =>  true,
                  :track_destroy  =>  true

  field :title, :type => String
  
  has_many :profiles

  def self.with_public_profile
    self.includes(:profiles).where(public_opts)
  end
  
  private
    def self.public_opts
      {"profiles.is_private" => {"$ne" => true}}
    end

end
