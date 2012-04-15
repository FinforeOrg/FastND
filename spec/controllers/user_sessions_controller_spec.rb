require 'spec_helper'

describe UserSessionsController do

	def valid_user_attributes
	end

	def valid_session
		{}
	end

	describe "GET create_network" do
		it "assigns twitter login" do
			get :network_sign_in, {:provider => "twitter"}
			assigns(:cat).should be_an_instance_of(String)
			assigns(:callback_url).should be_an_instance_of(String)
			session[assigns(:cat)].should_not be nil
			response.status.should be 200
		end
	end

end
