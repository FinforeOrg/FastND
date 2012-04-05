require 'spec_helper'

describe FeedAccount do
  before(:each) do
    @feed_account = FeedAccount.new
  end
  
  it { should have_fields(:title).of_type(String) }
  it { should have_fields(:category).of_type(String) }
  it { should have_fields(:window_type).of_type(String) }
  it { should have_fields(:position).of_type(Integer) }
  
  it { should have_index_for(:category) }
  
  it { should belong_to(:user) }
  it { should embed_one(:feed_token) }
  it { should embed_one(:keyword_column) }
  it { should have_many(:user_feeds) }
  
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:category) }
  
  it "should create keyword" do
    user = FactoryGirl.create(:user)
    token = {:token  => "klnsadzlknsdasdlkmsdfkn", :secret => "bzbnwdkmasdkndknsdfknsdf", :username => 12345}
    column = {:title => "Tech Podcasts", 
      :window_type => 'tab', 
      :category  => "portfolio", 
      :feed_token_attributes => token
    }    
    user.create_column(column)    
    
    keyword = {:keyword => "private equity europe", :follower => "100", :is_aggregate => true}
    
    feed_account = user.feed_accounts.first
    feed_account.keyword_column = KeywordColumn.new(keyword)
    feed_account.save
    feed_account.keyword_column.should_not be_nil
  end
  
  it "should be as twitter when category is twitter" do
    @feed_account.category = "twitter"
    @feed_account.isTwitter?.should be_true
  end
  
  it "should be as twitter when category is tweet" do
    @feed_account.category = "tweet"
    @feed_account.isTwitter?.should be_true
  end
  
  it "should be as twitter when category is suggested" do
    @feed_account.category = "suggested"
    @feed_account.isTwitter?.should be_true
  end
  
  it "should be as rss" do
    @feed_account.category = "rss"
    @feed_account.isRss?.should be_true
  end
  
  it "should be as linkedin when category is linkedin" do
    @feed_account.category = "linkedin"
    @feed_account.isLinkedin?.should be_true
  end
  
  it "should be as linkedin when category is linked-in" do
    @feed_account.category = "linked-in"
    @feed_account.isLinkedin?.should be_true
  end
  
  it "should be as podcast when category is podcast" do
    @feed_account.category = "podcast"
    @feed_account.isPodcast?.should be_true
  end
  
  it "should be as podcast when category is video" do
    @feed_account.category = "video"
    @feed_account.isPodcast?.should be_true
  end
  
  it "should be as podcast when category is audio" do
    @feed_account.category = "audio"
    @feed_account.isPodcast?.should be_true
  end
  
  it "should be as chart when category is price" do
    @feed_account.category = "price"
    @feed_account.isChart?.should be_true
  end
  
  it "should be as chart when category is chart" do
    @feed_account.category = "chart"
    @feed_account.isChart?.should be_true
  end
  
  it "should be as company when category is company" do
    @feed_account.category = "company"
    @feed_account.isCompany?.should be_true
  end
  
  it "should be as company when category is index" do
    @feed_account.category = "index"
    @feed_account.isCompany?.should be_true
  end
  
  it "should be as company when category is currency" do
    @feed_account.category = "currency"
    @feed_account.isCompany?.should be_true
  end
  
  it "should be as keyword" do
    @feed_account.category = "keyword"
    @feed_account.isKeyword?.should be_true
  end
  
  it "should be as portfolio" do
    @feed_account.category = "portfolio"
    @feed_account.isPortfolio?.should be_true
  end
  
  it "should be as followable to any twitter account when category suggested" do
    @feed_account.category = "suggested"
    @feed_account.isFollowable?.should be_true
  end
  
  it "should be as followable to any twitter account when category index" do
    @feed_account.category = "index"
    @feed_account.isFollowable?.should be_true
  end
  
end