class Profile
  include Mongoid::Document
  
  field :title, :type => String
  field :is_private, :type => Boolean
  
  index :title
  index :profile_category_id

  default_scope where(:is_private => false)   
  has_and_belongs_to_many :users, :index => true
  has_and_belongs_to_many :feed_infos, :index => true
  has_and_belongs_to_many :populate_feed_infos, :index => true
  belongs_to :profile_category, :index => true
  
  def self.without(disclude)
    self.all(:include=>:profile_category,
             :conditions=>"profile_categories.title !~* '#{disclude}'")
  end

  def as_json(options)
    options = {:include => {:profile_category => {:only => [:_id,:title]}},
               :only    => [:_id,:title]}
    super(options)
  end

  def self.public
     self.all(:conditions => "is_private IS NOT TRUE")
  end
  
end
