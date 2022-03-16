# frozen_string_literal: true

require_relative '../../../../tasks/utils/application'

RSpec.describe Application do
  subject(:application) { described_class.new(title: 'app', name: 'app', environment: 'production', path: path, deploy_user: Process.uid, deploy_group: Process.gid, user_mapping: {}, group_mapping: {}, retention_min: 5, retention_max: nil) }

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
