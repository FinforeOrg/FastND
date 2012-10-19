require 'spec_helper'

describe KeywordColumn do
  it { should have_fields(:keyword).of_type(String) }
  it { should have_fields(:is_aggregate).of_type(Boolean) }
  it { should have_fields(:follower).of_type(Integer) }
  
  it { should have_index_for(:keyword) }
  
  it { should be_embedded_in(:feed_account) }
end
