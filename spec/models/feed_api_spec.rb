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

end
