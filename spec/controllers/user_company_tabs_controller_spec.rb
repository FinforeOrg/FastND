require 'spec_helper'

describe UserCompanyTabsController do

	# This should return the minimal set of attributes required to create a valid
	# User. As you add validations to User, be sure to
	# update the return value of this method accordingly.
	def valid_user_attributes
		{:full_name => "John Doe",
		 :login => "john@doe.net",
		 :email_work => "john@doe.net",
		 :password => "johndoe123~",
		 :password_confirmation => "johndoe123~",
		 :user_company_tabs_attributes => valid_tab_attributes,
		 :profile_ids => ["1230000000001","1230000000002","1230000000003"]
		}
	end

	def tab_parameter
		{:user_company_tab => {:follower => 100, :is_aggregate => true, :feed_info_id => "4ed0d8cf7b3fc62cf5000b32"}}
	end

	def valid_tab_attributes
		[
			{:follower => 0, :is_aggregate => false, :feed_info_id => "4ed0d8cf7b3fc62cf5000b29"},
			{:follower => 100, :is_aggregate => false, :feed_info_id => "4ed0d8cf7b3fc62cf5000997"},
		]
	end
	
	def create_feed_infos
	  ["4ed0d8cf7b3fc62cf5000b32","4ed0d8cf7b3fc62cf5000b29","4ed0d8cf7b3fc62cf5000997"].each do |fid|
		  feed_info = FeedInfo.create({
		  	:_id => fid,
		  	:title => "Apple Inc.",
		  	:address => "$AAPL",
		  	:category => "Company"
		  })
		  CompanyCompetitor.create({:feed_info_id => feed_info.id,
		  	:bing_keyword => "NASDAQ:AAPL",
		  	:blog_keyword => "NASDAQ:AAPL",
		  	:broadcast_keyword => "Apple Inc",
		  	:company_keyword => "NASDAQ:AAPL",
		  	:company_ticker => "NASDAQ:AAPL",
		  	:competitor_ticker => "NASDAQ:MSFT,NASDAQ:GOOG,NYSE:IBM,NYSE:HPQ,NYSE:NOK,NASDAQ:DELL,NASDAQ:RIMM",
		  	:finance_keyword => "NASDAQ:AAPL",
		  	:keyword => "$MSFT,$GOOG,$GOOG,$IBM,$HPQ,$NOK,$DELL,$RIMM"
		  })
		end
	end

	# This should return the minimal set of values that should be in the session
	# in order to pass any filters (e.g. authentication) defined in
	# UsersController. Be sure to keep this updated too.
	def valid_session
		{}
	end

	def auth_params(user)
		{:auth_token => user.single_access_token, :auth_secret => user.persistence_token, :format => "json"}
	end

	def create_user!
		create_feed_infos
		@user = User.create! valid_user_attributes
		@user.should be_valid
	end

	describe "GET index" do
		it "assigns the requested columns" do
			create_user!
			@user_company_tabs = @user.user_company_tabs
			xhr :get, :index, auth_params(@user)
			assigns(:user_company_tabs).to_a.should_not be_empty
			assigns(:user_company_tabs).count.should == 2
			response.status.should be 200
		end
	end

	describe "GET show" do
		it "assigns the requested user company tab" do
			create_user!
			tab = @user.user_company_tabs.first
			xhr :get, :show, auth_params(@user).merge!(:id => tab.id.to_s)
			assigns(:user_company_tab).should_not be nil
			assigns(:user_company_tab).follower == tab.follower
			assigns(:user_company_tab).feed_info.should_not be nil
			response.status.should be 200
		end
	end

	describe "POST create" do
		it "assigns user company tab creation" do
			create_user!
			xhr :post, :create, auth_params(@user).merge!(tab_parameter)
			assigns(:user_company_tab).should_not be nil
			assigns(:user_company_tab).feed_info.category.should == "Company"
			assigns(:user_company_tab).should have(0).errors
			assigns(:user_company_tab).should be_an_instance_of UserCompanyTab
		end
		it "assigns user company tab creation by user parameter" do
			create_user!
			xhr :post, :create, auth_params(@user).merge!({:user => {:_id => @user.id, :user_company_tabs_attributes => valid_tab_attributes}})
			assigns(:user_company_tab).should be_an_instance_of User
			assigns(:user_company_tab).user_company_tabs.count.should == 4
		end
	end

	describe "DELETE destroy" do
		it "assigns tab deletion" do
			create_user!
			tab = @user.user_company_tabs.first
			xhr :delete, :destroy, auth_params(@user).merge!(:id => tab.id.to_s)
			assigns(:user_company_tab).should_not be nil
			@user.user_company_tabs.where(:_id => tab.id).first.should be nil
		end
	end
	
	
	describe "PUT update" do
		it "assigns update column" do
			create_user!
			tab = @user.user_company_tabs.first
			xhr :put, :update, auth_params(@user).merge!({:id => tab.id.to_s, :user_company_tab => {:_id => tab.id.to_s, :follower => 5000 }})
			assigns(:user_company_tab).should have(0).errors
			assigns(:user_company_tab).follower.should == 5000
		end
	end



end
