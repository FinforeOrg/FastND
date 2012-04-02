require 'spec_helper'

describe UserFeed do
  before(:each) do
    @user_feed = UserFeed.new
  end  
  
  it { should have_fields(:title).of_type(String) }
  it { should have_index_for(:title) }

  it { should belong_to(:feed_account) }
  it { should belong_to(:feed_info) }
  
  it "should accept nested attributes for feed_info" do
  end  
  
#  it "should be as suggestion when category is twitter" do
#    @user_feed.category_type = "twitter"
#    @user_feed.isSuggestion?.should be_true
#  end
#  
#  it "should be as suggestion when category is tweet" do
#    @user_feed.category_type = "tweet"
#    @user_feed.isSuggestion?.should be_true
#  end
#  
#  it "should be as suggestion when category is suggested" do
#    @user_feed.category_type = "suggested"
#    @user_feed.isSuggestion?.should be_true
#  end
#  
#  it "should be as rss" do
#    @user_feed.category_type = "rss"
#    @user_feed.isRss?.should be_true
#  end
#  
#  it "should be as podcast when category is podcast" do
#    @user_feed.category_type = "podcast"
#    @user_feed.isPodcast?.should be_true
#  end
#  
#  it "should be as podcast when category is video" do
#    @user_feed.category_type = "video"
#    @user_feed.isPodcast?.should be_true
#  end
#  
#  it "should be as podcast when category is audio" do
#    @user_feed.category_type = "audio"
#    @user_feed.isPodcast?.should be_true
#  end
#  
#  it "should be as chart when category is price" do
#    @user_feed.category_type = "price"
#    @user_feed.isChart?.should be_true
#  end
#  
#  it "should be as chart when category is chart" do
#    @user_feed.category_type = "chart"
#    @user_feed.isChart?.should be_true
#  end
#  
#  it "should be as company when category is company" do
#    @user_feed.category_type = "company"
#    @user_feed.isCompany?.should be_true
#  end
#  
#  it "should be as company when category is index" do
#    @user_feed.category_type = "index"
#    @user_feed.isCompany?.should be_true
#  end
#  
#  it "should be as company when category is currency" do
#    @user_feed.category_type = "currency"
#    @user_feed.isCompany?.should be_true
#  end
#  
#  it "should be as keyword" do
#    @user_feed.category_type = "keyword"
#    @user_feed.isKeyword?.should be_true
#  end 
  
end