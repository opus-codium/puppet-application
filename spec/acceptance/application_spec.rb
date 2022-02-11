require 'spec_helper_acceptance'

describe 'application' do
  it_behaves_like 'the example', 'garden-party.pp'
end
