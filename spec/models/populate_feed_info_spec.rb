require 'spec_helper'

describe PopulateFeedInfo do
  it { should have_fields(:is_company_tab).of_type(Boolean) }
  it { should belong_to(:feed_info) }
end