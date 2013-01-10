require 'spec_helper'

describe FeedToken do
  it { should have_fields(:token).of_type(String) }
  it { should have_fields(:secret).of_type(String) }
  it { should have_fields(:token_preauth).of_type(String) }
  it { should have_fields(:secret_preauth).of_type(String) }
  it { should have_fields(:url_oauth).of_type(String) }
  it { should have_fields(:username).of_type(String) }

  it { should have_index_for(:username) }
  it { should have_index_for(:token) }
  it { should have_index_for(:secret) }
  it { should have_index_for(:token_preauth) }
  it { should have_index_for(:secret_preauth) }

  it { should be_embedded_in(:feed_account) }
end
