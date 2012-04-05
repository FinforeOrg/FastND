require 'spec_helper'

describe UsersController do

	# This should return the minimal set of attributes required to create a valid
	# User. As you add validations to User, be sure to
	# update the return value of this method accordingly.
	def valid_attributes
		{:full_name => "John Doe",
		 :login => "john@doe.net",
		 :email_work => "john@doe.net",
		 :password => "johndoe123~",
		 :password_confirmation => "johndoe123~",
		 :feed_accounts_attributes => column_attributes,
		 :profile_ids => ["1230000000001","1230000000002","1230000000003"]
		}
	end
	
	def column_attributes
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
					},
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
		{:id => user.id, :auth_token => user.single_access_token, :auth_secret => user.persistence_token, :format => "json"}
	end
	
	describe "GET show" do
		it "assigns the requested user" do
			user = User.create! valid_attributes
			user.should be_valid
			xhr :get, :show, auth_params(user)
			assigns(:user).should_not be_nil
		end
	end
	
	describe "POST create" do
		it "assigns user creation" do
			xhr :post, :create, {:user => valid_attributes}
			assigns(:user).should_not be_nil
			assigns(:user).should have(0).errors
			assigns(:user).should have(3).user_profiles
		end
	end
	
	describe "PUT update" do
		describe "with valid params" do
			it "updates the requested User attribute" do
				user = User.create! valid_attributes
				User.any_instance.should_receive(:update_attributes).with({'full_name' => 'Jane Doe'})
				xhr :put, :update, auth_params(user).merge!(:user => {'full_name' => 'Jane Doe'})
			end
			it "updates the requested user's column" do
				user = User.create! valid_attributes
				column = user.feed_accounts.first
				changes = {'_id' => column.id.to_s, 'title' => 'Lorem'}
				FeedAccount.any_instance.should_receive(:update_attributes).with(changes)
				xhr :put, :update, auth_params(user).merge!(:user => {'feed_accounts_attributes' => [changes]})
			end
		end
		describe "with invalid params" do
			it "assigns a user as @user" do
				user = User.create! valid_attributes
				User.any_instance.stub(:save).and_return(false)
				xhr :put, :update, auth_params(user).merge!(:user => {:email_work => ""})
				assigns(:user).should eq(user)
				assigns(:user).should have(1).error_on(:email_work)
				response.status.should be 422 
			end
		end
	end
	
	describe "GET forgot_password" do
		it "changes old password to new password" do
			user = User.create! valid_attributes
			xhr :get, :forgot_password, {:email => "john@doe.net", :format => "json"}
			assigns(:user).should eq(user)
		end
	end

end
