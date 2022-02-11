# frozen_string_literal: true

require_relative '../../../../tasks/utils/application'

RSpec.describe Application do
  subject(:application) { described_class.new(name: 'app', path: path) }

  let(:path) { Dir.mktmpdir }

  before do
    application.deploy(nil, '1')
    application.deploy(nil, '2')
  end

  after do
    FileUtils.rm_r(path)
  end

  context '#deployments' do
    subject { application.deployments.count }

    it { is_expected.to eq(2) }
  end
end
