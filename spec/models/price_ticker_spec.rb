require 'spec_helper'

describe PriceTicker do
  it { should have_fields(:ticker).of_type(String) }
  it { should have_index_for(:ticker) }
  it { should belong_to(:feed_info) }
end