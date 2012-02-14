require 'spec_helper'

describe PopulateFeedInfo do
  it { should have_fields(:is_company_tab).of_type(Boolean) }
  it { should belong_to(:feed_info) }
  it { should have_and_belong_to_many(:profiles) }
end