require 'spec_helper'

describe UserFeedsController do

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

	def valid_column_attributes
		[
			{:name => "RSS Column", :category => "rss", 
				:user_feeds_attributes => [
					{:title => "Rss URL 1", 
					 :feed_info_attributes => {
						 :title => "Rss URL 1",
						 :address => "http://rss.domain.info/url_1.rss",
						 :category => "rss"
					 } 
					}
				]
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

	describe "PUT update" do
		it "assigns update feed" do
			create_user!
			column = @user.feed_accounts.first
			user_feed = column.user_feeds.first
			opts = {:id => user_feed.id.to_s, 
				      :feed_account_id => column.id.to_s, 
				      :user_feed => {:title => "Lorem Ipsum", :_id => user_feed.id.to_s}
				     }
			xhr :put, :update, auth_params(@user).merge!(opts)
			assigns(:user_feed).should have(0).errors
			assigns(:user_feed).title.should == "Lorem Ipsum"
		end
	end

	describe "DELETE destroy" do
		it "assigns feed deletion" do
			create_user!
			column = @user.feed_accounts.first
			user_feed = column.user_feeds.first
			xhr :delete, :destroy, auth_params(@user).merge!(:id => user_feed.id.to_s, :feed_account_id => column.id.to_s)
			assigns(:user_feed).should_not be nil
			UserFeed.where(:_id => user_feed.id).first.should be nil
		end
	end


end
