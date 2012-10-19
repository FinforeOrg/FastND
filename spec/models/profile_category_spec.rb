require 'spec_helper'

describe ProfileCategory do
  it { should have_fields(:title).of_type(String) }
  it { should have_many(:profiles) }
end