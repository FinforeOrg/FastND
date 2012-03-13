class FeedInfo
  include Mongoid::Document
  include Finforenet::Models::SharedQuery
  include Finforenet::Models::Jsonable
  
  #Fields
  field :title,       :type => String 
  field :address,     :type => String 
  field :category,    :type => String 
  field :follower,    :type => Integer, :default => 0 
  field :image,       :type => String 
  field :description, :type => String
  field :is_populate, :type => Boolean, :default => false
  #this indicates that feed_info is from user inputs
  field :is_user,     :type => Boolean, :default => false 
  
  index :title
  index :address
  index :category
  index :is_populate
  
  #Associations
  #Please do not use embeds to relations below, because they're separated collections
  
  #has_many :user_feeds,          :dependent => :destroy
  has_many :populate_feed_infos, :dependent => :destroy, :index => true
  has_many :price_tickers,       :dependent => :destroy, :index => true
  #has_many :user_company_tabs,   :dependent => :destroy
  has_one  :company_competitor,  :dependent => :destroy, :index => true
  has_and_belongs_to_many :profiles, :index => true
  
  validates :title,    :presence => true
  validates :address,  :presence => true
  validates :category, :presence => true

  #cache
  
  def as_json(options={})
    if options[:include].blank?
	  
      options = {:include => {:price_tickers => {:only => [:ticker]}, 
	                          :company_competitor => { :except=> [:feed_info_id] }, 
	                          :profiles => {:only => [:_id,:title],:include  => profile_category_opts}
	                         }, 
	             :except => [:profile_ids]
	            }
    end
    super(options)
  end

  def self.filter_feeds_data(conditions, limit_no, page)
	feed_infos = self.includes(:profiles) if conditions[:profile_ids]
	feed_infos = self.where(conditions).asc(:title)
	#feed_infos = feed_infos.limit(limit_no) unless limit_no.blank?
	#unless page.blank?
	#  if page == 1
	#	offset_no = 0 
	#  else
	#	offset_no = page * limit_no
	#  end
	#end
	#feed_infos = feed_infos.offset(offset_no) 
    return feed_infos
  end

  def self.all_with_competitor(conditions)
    results = self.includes(:company_competitor).where(conditions)
    results = results.sort_by{|r| r.profiles.count}.reverse if conditions[:profile_ids]
    return results
  end

  def self.all_sort_title(conditions)
	self.includes(:price_tickers).where(conditions).asc(:title)
  end

  def self.search_populates(options,is_company_tab=false)
    feed_infos = self.where(options)
    if is_company_tab
      feed_infos = feed_infos.select{|info| info if !info.company_competitor.blank? }
    end
    feed_infos = feed_infos.sort{|fi| fi.profile_ids.size}.sort{|x,y| y.profile_ids.size <=> x.profile_ids.size}
 
    if feed_infos.size < 4 && !is_company_tab
      current_ids = feed_infos.map(&:id)
      options.merge!({"$nin" => current_ids})
      more_results = self.where(options).limit(4-feed_infos.size)
      feed_infos += more_results
    else
      feed_infos = feed_infos.slice(0,4)
    end

    return feed_infos
  end

  def self.with_populated_prices
    self.where(:title => /(DJ Indus)|(Equity Indi)/i)
  end

  def isSuggestion?
    self.category =~ /(tweet|twitter|suggest)/i
  end

  def isRss?
    self.category =~ /(rss)/i
  end

  def isPodcast?
   self.category =~ /(podcast|video|audio)/i
  end

  def isChart?
    self.category =~ /(price|chart)/i
  end

  def isCompany?
    self.category =~ /(company|index|currency)/i
  end

  def isKeyword?
    self.category =~ /(keyword)/i
  end


end
