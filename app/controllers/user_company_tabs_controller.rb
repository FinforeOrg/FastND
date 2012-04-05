class UserCompanyTabsController < ApplicationController
  
  def index
    @user_company_tabs = current_user.user_company_tabs
    api_responds(@user_company_tabs)
  end

  def create
	  if params[:user]
  	  @user_company_tab = current_user
	    @user_company_tab.update_attributes(params[:user])
	  else
	    @user_company_tab = current_user.user_company_tabs.create(params[:user_company_tab])
	  end
	  @user_company_tab.valid? ? api_responds(@user_company_tab) : error_responds(@user_company_tab)
  end
  
  def show
	  @user_company_tab = current_user.user_company_tabs.find(params[:id])
	  api_responds(@user_company_tab)
	end

  def update
    @user_company_tab = current_user.user_company_tabs.find(params[:id])
    @user_company_tab.update_attributes(params[:user_company_tab]) ? api_responds(@user_company_tab) : error_responds(@user_company_tab)
  end

  def destroy
    @user_company_tab = current_user.user_company_tabs.find(params[:id])
    @user_company_tab.destroy if @user_company_tab
    api_responds(@user_company_tab)
  end

end
