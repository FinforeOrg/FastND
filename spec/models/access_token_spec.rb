require 'spec_helper'

describe AccessToken do
  it { should have_fields(:category).of_type(String) }
  it { should have_fields(:token).of_type(String) }
  it { should have_fields(:secret).of_type(String) }
  it { should have_fields(:username).of_type(String) }

  it { should have_index_for(:category) }
  it { should have_index_for(:username) }
  
  it { should belong_to(:user) }
end
