require 'spec_helper'

describe FeedInfo do
  before(:each) do
    @feed_info = FeedInfo.new
    FactoryGirl.create(:feed_info_abb)
    FactoryGirl.create(:feed_info_paribas)    
    
    technology = FactoryGirl.create(:profile_technology)
    asset = FactoryGirl.create(:profile_asset)
    banking = FactoryGirl.create(:profile_banking)
    
    @user = FactoryGirl.create(:user)
    @user.profiles.concat([technology, asset, banking])
    
    equity = FactoryGirl.create(:feed_info_equity)
    equity.profiles.concat([technology, asset, banking])
    
    industrials = FactoryGirl.create(:feed_info_industrials)
    industrials.profiles.concat([technology, asset, banking])
    
    asx = FactoryGirl.create(:feed_info_asx)
    asx.profiles.concat([technology, asset, banking])
    
    
    
  end  
  
  it { should have_fields(:title).of_type(String) }
  it { should have_fields(:address).of_type(String) }
  it { should have_fields(:category).of_type(String) }
  it { should have_fields(:follower).of_type(Integer) }
  it { should have_fields(:image).of_type(String) }
  it { should have_fields(:description).of_type(String) }
  it { should have_fields(:is_populate).of_type(Boolean) }
  it { should have_fields(:is_user).of_type(Boolean) }
  
  it { should have_index_for(:title) }
  it { should have_index_for(:address) }
  it { should have_index_for(:category) }
  it { should have_index_for(:is_populate) }

  it { should have_many :populate_feed_infos }
  it { should have_many :price_tickers }
  it { should have_one(:company_competitor) }  
  it { should have_and_belong_to_many(:profiles) }
  
  it { should validate_presence_of(:title) }  
  it { should validate_presence_of(:address) }  
  it { should validate_presence_of(:category) }
  
  it "should show feed info as json" do
    FeedInfo.first.as_json.class.should == Hash
  end  
  
  it "it should show feed info all with competitor" do 
    conditions = FeedInfo.send("company_query")
    feed_info_with_competitor = FeedInfo.all_with_competitor(conditions)
    feed_info_with_competitor.size.should == 2
  end
  
  it "it should show feed info all sort title" do 
    conditions = FeedInfo.send("chart_query")
    feed_info_all_sort_title = FeedInfo.all_sort_title(conditions)
    feed_info_all_sort_title.size.should == 3
  end
  
  it "it should search populates feed info" do 
#    include Finforenet::Models::SharedQuery
#    require "ruby-debug";debugger
#    conditions = FeedInfo.send("chart_query")
#    conditions = populated_query(conditions).merge!(profiles_query(@user))
#    feed_info_populates = FeedInfo.search_populates(conditions)    
    
  end
  
  it "should show feed info with populated prices" do
    feed_info_with_populated_prices =  FeedInfo.with_populated_prices
    feed_info_with_populated_prices.size.should == 2
  end
  
  it "should be as suggestion when category is twitter" do
    @feed_info.category = "twitter"
    @feed_info.isSuggestion?.should be_true
  end
  
  it "should be as suggestion when category is tweet" do
    @feed_info.category = "tweet"
    @feed_info.isSuggestion?.should be_true
  end
  
  it "should be as suggestion when category is suggested" do
    @feed_info.category = "suggested"
    @feed_info.isSuggestion?.should be_true
  end
  
  it "should be as rss" do
    @feed_info.category = "rss"
    @feed_info.isRss?.should be_true
  end
  
  it "should be as podcast when category is podcast" do
    @feed_info.category = "podcast"
    @feed_info.isPodcast?.should be_true
  end
  
  it "should be as podcast when category is video" do
    @feed_info.category = "video"
    @feed_info.isPodcast?.should be_true
  end
  
  it "should be as podcast when category is audio" do
    @feed_info.category = "audio"
    @feed_info.isPodcast?.should be_true
  end
  
  it "should be as chart when category is price" do
    @feed_info.category = "price"
    @feed_info.isChart?.should be_true
  end
  
  it "should be as chart when category is chart" do
    @feed_info.category = "chart"
    @feed_info.isChart?.should be_true
  end
  
  it "should be as company when category is company" do
    @feed_info.category = "company"
    @feed_info.isCompany?.should be_true
  end
  
  it "should be as company when category is index" do
    @feed_info.category = "index"
    @feed_info.isCompany?.should be_true
  end
  
  it "should be as company when category is currency" do
    @feed_info.category = "currency"
    @feed_info.isCompany?.should be_true
  end
  
  it "should be as keyword" do
    @feed_info.category = "keyword"
    @feed_info.isKeyword?.should be_true
  end   
  
end  