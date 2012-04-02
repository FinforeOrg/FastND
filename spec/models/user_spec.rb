require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end
  
  it { should have_fields(:email_work).of_type(String) }
  it { should have_fields(:login).of_type(String) }
  it { should have_fields(:full_name).of_type(String) } 
  it { should have_fields(:is_online).of_type(Boolean).with_default_value_of(false) }  
  it { should have_fields(:is_public).of_type(Boolean).with_default_value_of(false) }  
  
  it { should have_index_for(:email_work) }
  it { should have_index_for(:login) }
  it { should have_index_for(:full_name) }
  
  it { should have_many(:access_tokens) }
  it { should have_many(:feed_accounts) }
  it { should have_many(:user_company_tabs) }
  
  it { should have_many(:user_profiles) }
  it { should validate_format_of(:email_work) }
  
  
  it "should accept nested attributes for access_tokens" do
    user = FactoryGirl.build(:user)
    user.access_tokens_attributes = [{:name => "child"}]
    user.save;
    user.access_tokens.size.should == 1
    user.access_tokens.first.name.should == "child"
  end
  
  it "should accept nested attributes for feed_accounts" do
  end
  
  it "should accept nested attributes for user_company_tabs" do
  end
  
  it "should create_column" do
    token = {:token  => "klnsadzlknsdasdlkmsdfkn", :secret => "bzbnwdkmasdkndknsdfknsdf", :username => 12345}
    column = {:name => "Tech Podcasts",
      :window_type => 'tab', 
      :category  => "podcast", 
      :feed_token_attributes => token
    }    
    @user.create_column(column).should_not be false
  end  
  
  it "should have column with category portfolio" do
    token = {:token  => "klnsadzlknsdasdlkmsdfkn", :secret => "bzbnwdkmasdkndknsdfknsdf", :username => 12345}
    column = {:name => "Tech Podcasts", 
      :window_type => 'tab', 
      :category  => "portfolio", 
      :feed_token_attributes => token
    }    
    @user.create_column(column).should_not be false
  end  
  
  it "should create tab" do
  end
  
  it "email work should exist" do
    user = User.new
    user.is_exist("john@doe.com").first.should == "is already taken."
    
  end
  
  it "email work should not exist" do
    user = User.new
    user.is_exist("jane@doe.com").should be_nil
  end
  
  it "should create autopopulate" do
  end
  
  it "should have not columns" do
    columns = @user.has_columns?
    columns.should be_false
  end
  
  it "should have columns" do
    token = {:token  => "klnsadzlknsdasdlkmsdfkn", :secret => "bzbnwdkmasdkndknsdfknsdf", :username => 12345}
    column = {:name => "Tech Podcasts", 
      :window_type => 'tab', 
      :category  => "podcast", 
      :feed_token_attributes => token
    }    
    @user.create_column(column)
    columns = @user.has_columns?
    columns.should be_true
  end
  
  it "should able find by id" do
    user_id = FactoryGirl.create(:jane).id
    user = User.find_by_id(user_id)
    user.full_name.should == "Jane Doe"
  end
  
  it "should not able find by id" do
    user_id = 123456789
    user = User.find_by_id(user_id)
    user.should be_nil
  end
  
  it "should able find by username" do
    @user.access_tokens << FactoryGirl.build(:access_token)
    user = User.by_username("g-C_xaKPQb")
    user.full_name.should == 'John Doe'
  end
  
  it "should able to find user by auth_by_security" do
    user = User.auth_by_security(@user.single_access_token, @user.perishable_token)
    user.full_name.should == 'John Doe'
  end
  
  it "should able to find user by auth_by_security with user is blank and public is true" do
    @user.update_attribute(:is_public, true)
    user = User.auth_by_security(@user.single_access_token, "11qedskjdnsfkln2")
    user.full_name.should == 'John Doe'
  end
  
  it "should able to user by auth_by_persistence" do
    user = User.auth_by_persistence(@user.single_access_token, @user.persistence_token)
    user.full_name.should == 'John Doe'
  end
  
  it "should find_public_profile" do
  end
  
  it "should has_email?" do
    @user.has_email?.should be_true
  end
  
  it "should not_social_login?" do
    @user.not_social_login?.should be_false
  end
  
  it "should be not_social_login?" do
    @user.access_tokens << FactoryGirl.build(:access_token)
    @user.not_social_login?.should be_true
  end
  
  it "should focuses_by_category" do
  end
  
  
  
end
