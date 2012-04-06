class FeedInfo < Base::FeedInfo  
  field :is_populate, :type => Boolean, :default => false
  index :is_populate

  validates :title,    :presence => true
  #Associations
  has_many :user_feeds,          :dependent => :destroy
  has_many :price_tickers,       :dependent => :destroy
  has_many :user_company_tabs,   :dependent => :destroy
  has_one  :company_competitor,  :dependent => :destroy
  has_many :feed_info_profiles,  :dependent => :destroy, :class_name => "FeedInfo::Profile"

  def self.filter_feeds_data(conditions, _limit, _page)
	  feed_infos = self.includes(:feed_info_profiles) if conditions[:_id]
	  return self.where(conditions).asc(:title)
  end

  def self.all_with_competitor(conditions)
    results = self.includes(:company_competitor).where(conditions)
    results = results.sort_by{|r| r.profiles.count}.reverse if conditions[:profile_ids]
    return results
  end

  def self.all_sort_title(conditions)
    return self.includes(:price_tickers).where(conditions).asc(:title)
  end

  #TODO : Tear down this method if not used yet
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
