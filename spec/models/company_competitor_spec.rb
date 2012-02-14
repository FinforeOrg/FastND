require 'spec_helper'

describe CompanyCompetitor do
  it { should have_field(:keyword).of_type(String) }
  it { should have_field(:competitor_ticker).of_type(String) }
  it { should have_field(:company_keyword).of_type(String) }
  it { should have_field(:broadcast_keyword).of_type(String) }
  it { should have_field(:finance_keyword).of_type(String) }
  it { should have_field(:bing_keyword).of_type(String) }
  it { should have_field(:blog_keyword).of_type(String) }
  it { should have_field(:company_ticker).of_type(String) }

 it { should belong_to(:feed_info) }

 it "should create a columns" do 
   company = FactoryGirl.create(:nyse_company)
   columns = {:bing_keyword => "NYSE:BA", 
      :blog_keyword => "NYSE:BA, Boeing", 
      :company_ticket  => "NYSE:BA", 
      :feed_info_id    => 1 }
   company.save
   company.should_not be_nil    
 end

end
