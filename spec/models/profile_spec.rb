require 'spec_helper'

describe Profile do
  before(:each) do
    @profile_banking = FactoryGirl.create(:profile_banking)
    @profile = Profile.new
  end

  it { should have_fields(:title).of_type(String) }
  it { should have_fields(:is_private).of_type(Boolean) }
  
  it { should have_index_for(:title) }
  it { should have_many(:user_profiles) }
  it { should have_many(:feed_info_profiles) }
  it { should belong_to(:profile_category) }

  it 'should find public profile if is_private is not true' do
    @profile_banking.save
    #Profile.public.should_not be_nil
  end
  
  it 'should find record when title without a disclude' do
    @profile_category = ProfileCategory.new
    @profile_category.profiles.first
    columns = {:title => "test"}
    @profile_category.save
    
    #Profile.without("test")
  end 
end
