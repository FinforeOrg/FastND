FactoryGirl.define do
  factory :user do
    full_name 'John Doe'
    login 'johndoe'
    email_work 'john@doe.com'
    password "john12345"
    password_confirmation "john12345"
  end  
  
  factory :jane, :class => User do
    full_name 'Jane Doe'
    login 'janedoe'
    email_work 'doe@jane.com'
    password "jane1doe"
    password_confirmation "jane1doe"
  end  
  
  factory :james, :class => User do
    full_name 'James Doe'
    login 'jamesdoe'
    email_work 'james@doe.com'
    password "james1doe"
    password_confirmation "james1doe"
  end  
  
  factory :feed_token, :class => FeedToken do
    token "1/i7ZBS9nmVJNtLoK2u2ToQVSXL2bOaAuIHfXaaTmGORU"
    secret "kEx0eRESw3xTwlF31SoilJ5r"
    token_preauth null
    secret_preauth null
    url_oauth null
    username null
  end  
  
  factory :keyword_column_eastern_europe, :class => KeywordColumn do
    follower 0
    is_aggregate false
    keyword "eastern europe"
  end  
  
  factory :keyword_column_equity_europe, :class => KeywordColumn do
    follower 100
    is_aggregate true
    keyword "private equity europe"
  end  
  
  factory :keyword_column_pakistan_cricket, :class => KeywordColumn do
    follower 100
    is_aggregate true
    keyword "pakistan cricket" 
  end  
  
  factory :feed_account_portfolio, :class => FeedAccount do
    title "portfolio"
    category "portfolio"
    window_type null
  end  
  
  factory :feed_account_rss, :class => FeedAccount do
    title "FT WSJ and Economist"
    category "rss" 
    window_type "tab"
  end  
  
  factory :access_token, :class => AccessToken do
    category "linkedin"
    token "ae23da52-eb85-41c2-a5fd-99eae5b7964f"
    secret "4475606a-ed2b-4292-9092-4fc1cf1c6869"
    username "g-C_xaKPQb"
  end  
  
  factory :profile_technology, :class => Profile do
    title "Technology"
    is_private true
  end  
  
  factory :profile_asset, :class => Profile do
    title "Asset Management"
    is_private true
  end  
  
  factory :profile_banking, :class => Profile do
    title "Investment Banking"
    is_private false
  end  
  
  factory :gmail_feed_api, :class => FeedApi do
    category "gmail"
    
  end

  factory :nyse_company, :class => CompanyCompetitor do
    keyword "$HON,$LMT,$GD,$NOC,$RTN"
    competitor_ticker "NYSE:HON,NYSE:LMT,NYSE:GD,NYSE:NOC,NYSE:RTN"
    company_keyword "NYSE:BA, Boeing"
    broadcast_keyword "Boeing"
    finance_keyword "NYSE:BA"    
  end
  
  factory :feed_info_boeing, :class => FeedInfo do
    title "Boeing"
    address "$BA"
    category "Company"
  end
  
  factory :company_competitor_boeing, :class => CompanyCompetitor do
    broadcast_keyword "Boeing"
    bing_keyword "NYSE:BA,\"Boeing\""
    company_ticker "NYSE:BA"
    blog_keyword "NYSE:BA,\"Boeing\""
    finance_keyword "NYSE:BA"
    company_keyword "NYSE:BA,\"Boeing\""
    competitor_ticker "NYSE:HON,NYSE:LMT,NYSE:GD,NYSE:NOC,NYSE:RTN"
    keyword "$HON,$LMT,$GD,$NOC,$RTN"
  end
  
  factory :feed_info_paribas, :class => FeedInfo do
    title "BNP Paribas"
    address "BNPP"
    category "Company"
    association :company_competitor, :factory => :company_competitor_boeing
  end
  
  # Message: Poundsterling & Euro symbols were changed by yacobus
  #          because they gave error when running rspec in console
  factory :company_competitor_paribas, :class => CompanyCompetitor do
    broadcast_keyword "\"BNP Paribas\""
    bing_keyword "EPA:BNP, \"BNP Paribas\""
    company_ticker "EPA:BNP"
    blog_keyword "EPA:BNP, \"BNP Paribas\""
    finance_keyword "EPA:BNP"
    company_keyword "EPA:BNP, \"BNP Paribas\""
    competitor_ticker "EPA:GLE,EPA:ACA,BIT:UCG,BIT:BMPS,BIT:CRG,BIT:PMI,LON:BARC,LON:HSBC,LON:RBS,LON:LLOY,LON:STAN,NYSE:JPM,NYSE:BAC,NYSE:C,NYSE:GS,NYSE:MS"
    keyword "ISP,BMPS,CRG,PMI,$HBC,$BAC,$C,$GS,$MS,HSBA,RBS,LLOY,STAN,$RBS,$LYG,BARC,$BCS,GLE,ACA,UCG"
  end  
  
  factory :feed_info_abb, :class => FeedInfo do
    title "ABB"
    address "#ABBN"
    category "Company"
  end
  
  factory :feed_info_equity, :class => FeedInfo do
    title "Equity Indices"
    address "0Aki7c9jXinAsdFFaVmFfM0J2ZmFWY3FsangwQ3VBclE"
    category "Chart"
    follower 3
  end
  
  factory :feed_info_industrials, :class => FeedInfo do
    title "DJ Industrials"
    address "0Aj4_lHTRQg9LdDI1dWRZZUlLdy1zWXRlanUtTjMxR2c"
    category "Chart"
  end
  
  factory :feed_info_asx, :class => FeedInfo do
    title "ASX SP 20"
    address "0Aki7c9jXinAsdExDcnNFV21EYi1raXY4blMxcWxwZUE"
    category "Chart"
  end
  
  factory :price_ticker_asx, :class => PriceTicker do
    ticker "ASX:AMP"
  end  
  
  factory :price_ticker_equity, :class => PriceTicker do
    ticker "INDEXASX:XJO"
  end  
  
  factory :price_ticker_dj, :class => PriceTicker do
    ticker "NYSE:MMM"
  end  
  
  factory :price_ticker_dja, :class => PriceTicker do
    ticker "NYSE:AA"
  end  
  
  factory :price_ticker_djx, :class => PriceTicker do
    ticker "NYSE:AXP"
  end  
 
  
end
