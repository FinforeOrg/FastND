require 'spec_helper'

describe UserFeed do
  
  it { should have_fields(:title).of_type(String) }
  it { should have_index_for(:title) }

  it { should belong_to(:feed_account) }
  it { should belong_to(:feed_info) }
  it { should embed_one(:custom_feed_info) }
  
  it "should accept create custom feed info && run filter_attributes" do
    feed = UserFeed.create({:title => "Rss URL 1", 
                         :feed_info_attributes => {
                           :title => "Rss URL 1",
                           :address => "http://rss.domain.info/url_1.rss",
                           :category => "rss"
                          } 
                        })
    feed.feedinfo.title.should == "Rss URL 1"
  end
  
  it "should create UserFeed::FeedInfo, not FeedInfo for custom column resource" do
    feed = UserFeed.create({:title => "Rss URL 1", 
     :feed_info_attributes => {
       :title => "Rss URL 1",
       :address => "http://rss.domain.info/url_1.rss",
       :category => "rss"
      } 
    })
    feed.feed_info.should be nil
    feed.feedinfo.should be_an_instance_of(UserFeed::FeedInfo)
  end
  
end