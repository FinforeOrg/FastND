class UserCompanyTabsController < ApplicationController
  
  
  def index
    @user_company_tabs = current_user.user_company_tabs
    
    respond_to do |format|
      respond_to_do(format,@user_company_tabs)
    end
  end

  # POST /user_company_tabs
  # POST /user_company_tabs.xml
  def create
	if params[:user]
	  tabs = current_user.update_attributes(params[:user])
	else
	  tabs = current_user.user_company_tabs.create(params[:user_company_tab])
	end
	
	tab = tabs.class.equal?(Array) ? tabs.last : tabs
	
    respond_to do |format|
      if tab && tab.errors.size < 1
        respond_to_do(format,tabs)
      else
        respond_error_to_do(format,tab)
      end
    end

  end
  
  def show
	@user_company_tab = current_user.user_company_tabs.find(params[:id])
	respond_to do |format|
      respond_to_do(format,@user_company_tab)
    end
  end

  # PUT /user_company_tabs/1
  # PUT /user_company_tabs/1.xml
  def update
    @user_company_tab = current_user.user_company_tabs.find(params[:id])

    respond_to do |format|
      if @user_company_tab.update_attributes(params[:user_company_tab])
        respond_to_do(format,@user_company_tab)
      else
        respond_error_to_do(format,@user_company_tab)
      end
    end
  end

  # DELETE /user_company_tabs/1
  # DELETE /user_company_tabs/1.xml
  def destroy
    @user_company_tab = current_user.user_company_tabs.find(params[:id])
    @user_company_tab.destroy if @user_company_tab

    respond_to do |format|
      if @user_company_tab.update_attributes(params[:user_company_tab])
        respond_to_do(format,@user_company_tab)
      else
        respond_error_to_do(format,@user_company_tab)
      end
    end
  end

end
