require 'spec_helper'

describe FeedApi do
  before(:each) do
    @feed_api = FeedApi.new   
  end

  it { should have_fields(:category).of_type(String) }
  it { should have_fields(:secret).of_type(String) }
  it { should have_fields(:api).of_type(String) }
  it { should have_index_for(:category) }

  it "should assign a value to category" do
    @feed_api.category = "linkedin"
    @feed_api.category.should == "linkedin"
  end
  
  it "should give nil value when category is not facebook" do 
    @feed_api.category = "linkedid"
    @feed_api.isFacebook?.should be_nil
    @feed_api.isFacebook?.should be_false
  end

  it "should give nil value when auth by google if there's not a record" do
    FeedApi.auth_by("gmail").should be_nil
  end
  
  it "shoud return true if isLinkedin? is called" do
    api = FactoryGirl.create(:linkedin_feed_api)
    api.isLinkedin?.should_not be nil
    api.isLinkedin?.should be_an_instance_of(Fixnum)
  end
  
  it "shoud return true if isFacebook? is called" do
    api = FactoryGirl.create(:facebook_feed_api)
    api.isFacebook?.should_not be nil
    api.isFacebook?.should be_an_instance_of(Fixnum)
  end
  
  it "shoud return true if isTwitter? is called" do
    api = FactoryGirl.create(:twitter_feed_api)
    api.isTwitter?.should_not be nil
    api.isTwitter?.should be_an_instance_of(Fixnum)
  end
  
  it "shoud return true if isGoogle? is called" do
    api = FactoryGirl.create(:google_feed_api)
    api.isGoogle?.should_not be nil
    api.isGoogle?.should be_an_instance_of(Fixnum)
  end

end
