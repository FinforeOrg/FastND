require 'spec_helper'

describe UserCompanyTab do
  it { should have_fields(:follower).of_type(Integer) }
  it { should have_fields(:is_aggregate).of_type(Boolean) }
  it { should have_fields(:position).of_type(Integer) }

  it { should be_embedded_in(:user) }
  it { should belong_to(:feed_info) }
end