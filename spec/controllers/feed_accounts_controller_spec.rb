require 'spec_helper'

describe FeedAccountsController do

	# This should return the minimal set of attributes required to create a valid
	# User. As you add validations to User, be sure to
	# update the return value of this method accordingly.
	def valid_user_attributes
		{:full_name => "John Doe",
		 :login => "john@doe.net",
		 :email_work => "john@doe.net",
		 :password => "johndoe123~",
		 :password_confirmation => "johndoe123~",
		 :feed_accounts_attributes => valid_column_attributes,
		 :profile_ids => ["1230000000001","1230000000002","1230000000003"]
		}
	end
	
	def column_parameter
		{:feed_account => {:title => "RSS Column", :category => "rss", 
			:user_feeds_attributes => [
				{:title => "Custom Rss", 
				 :feed_info_attributes => {
					 :title => "Custom Feed 1",
					 :address => "http://rss.customdomain.org/feed_1.rss",
					 :category => "rss"
				 } 
				}
			]
		}}
	end

	def valid_column_attributes
		[
			{:title => "RSS Column", :category => "rss", 
				:user_feeds_attributes => [
					{:title => "Rss URL 1", 
					 :feed_info_attributes => {
						 :title => "Rss URL 1",
						 :address => "http://rss.domain.info/url_1.rss",
						 :category => "rss"
					 } 
					},
					{:title => "Rss URL 2", 
					 :feed_info_attributes => {
						 :title => "Rss URL 2",
						 :address => "http://rss.domain.info/url_2.rss",
						 :category => "rss"
					 } 
					},
				]
			},
			{:title => "PODCAST Column", :category => "podcast",
				:user_feeds_attributes => [
					{:title => "Podcast 1", 
					 :feed_info_attributes => {
						 :title => "Podcast 1",
						 :address => "http://podcast.domain.info/podcurl_1.rss",
						 :category => "podcast"
					 } 
					},
					{:title => "Podcast 2", 
					 :feed_info_attributes => {
						 :title => "Podcast 2",
						 :address => "http://podcast.domain.info/podcurl_2.rss",
						 :category => "podcast"
					 } 
					}
				]
			},
			{:title => "KEYWORD Column", :category => "keyword", 
				:keyword_column_attributes => {
					:keyword => "lorem, ipsum, dolor, cit",
					:is_aggregate => true,
					:follower => 100
				}
			}
		]
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
		@user = User.create! valid_user_attributes
		@user.should be_valid
	end

	describe "GET index" do
		it "assigns the requested columns" do
			create_user!
			@columns = @user.feed_accounts
			xhr :get, :index, auth_params(@user)
			assigns(:columns).to_a.should_not be_empty
			assigns(:columns).count.should == 3
			response.status.should be 200
		end
	end
	
	describe "GET show" do
		it "assigns the requested column" do
			create_user!
			column = @user.feed_accounts.last
			xhr :get, :show, auth_params(@user).merge!(:id => column.id.to_s)
			assigns(:column).should_not be nil
			assigns(:column).category.should == column.category
			assigns(:column).keyword_column.should_not be nil
			assigns(:column).keyword_column.keyword.should eq(column.keyword_column.keyword)
			response.status.should be 200
		end
	end
	
	describe "POST create" do
		it "assigns column creation" do
			create_user!
			xhr :post, :create, auth_params(@user).merge!(column_parameter)
			assigns(:column).should_not be nil
			assigns(:column).category.should == "rss"
			assigns(:column).should have(1).user_feeds
			assigns(:column).should have(0).errors
			response.should_not redirect_to(feed_accounts_url(auth_params(@user)))
		end
		it "assigns columns creation by user parameter" do
			create_user!
			xhr :post, :create, auth_params(@user).merge!({:user => {:_id => @user.id, :feed_accounts_attributes => valid_column_attributes}})
			assigns(:column).should be_an_instance_of Array
			assigns(:column).count.should == 6
			User.count.should == 1
		end
	end
	
	describe "PUT update" do
		it "assigns update column" do
			create_user!
			column = @user.feed_accounts.last
			xhr :put, :update, auth_params(@user).merge!({:id => column.id.to_s, :feed_account => {:_id => column.id.to_s, :title => "foo" }})
			assigns(:column).should have(0).errors
			assigns(:column).title.should == "foo"
		end
		it "assigns update column & create feed" do
			create_user!
			column = @user.feed_accounts.first
			opts = {:feed_account => {
				        :_id => column.id.to_s, 
				        :title => "foo", 
				        :user_feeds_attributes => [
				        	{:title => "Podcast 1", 
				        	 :feed_info_attributes => {
				        		 :title => "Podcast 1",
				        		 :address => "http://podcast.domain.info/podcurl_1.rss",
				        		 :category => "rss"
				        	 } 
				        	},
				        	{:title => "Podcast 2", 
				        	 :feed_info_attributes => {
				        		 :title => "Podcast 2",
				        		 :address => "http://podcast.domain.info/podcurl_2.rss",
				        		 :category => "rss"
				        	 } 
				        	}
				        ]
				       }, :id => column.id.to_s
			       }
			xhr :put, :update, auth_params(@user).merge!(opts)
			assigns(:column).should have(0).errors
			assigns(:column).title.should == "foo"
			assigns(:column).should have(4).user_feeds
			assigns(:column).user_feeds.last.title.should == "Podcast 2"
		end
	end
	
	describe "DELETE destroy" do
		it "assigns column deletion" do
			create_user!
			column = @user.feed_accounts.first
			xhr :delete, :destroy, auth_params(@user).merge!(:id => column.id.to_s)
			assigns(:column).should_not be nil
			@user.feed_accounts.where(:_id => column.id).first.should be nil
		end
	end


end
