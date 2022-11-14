# frozen_string_literal: true

require 'spec_helper'

require 'mtree'

require_relative '../../../../tasks/utils/application'
require_relative '../../../../tasks/utils/deployment'

def fixture(file)
  File.join(__dir__, '..', '..', 'fixtures', file)
end

RSpec.describe Deployment do
  subject(:deployment) { described_class.new(application, deployment_name) }

  let(:application) { Application.new(title: 'app', name: 'app', environment: 'production', path: path, deploy_user: Process.uid, deploy_group: Process.gid, user_mapping: user_mapping, group_mapping: group_mapping, retention_min: 5, retention_max: nil) }
  let(:deployment_name) { '12345678' }

  let(:path) { Dir.mktmpdir }
  let(:user_mapping) { {} }
  let(:group_mapping) { {} }

  after do
    FileUtils.rm_r(path)
  end

  describe '#activate' do
    before do
      allow(application).to receive(:current_link_path).and_return("#{path}/current")
      allow(File).to receive(:directory?).with("#{path}/12345678").and_return(true)
      allow(FileUtils).to receive(:rm_f).with("#{path}/current")
      allow(FileUtils).to receive(:ln_s).with("#{path}/12345678", "#{path}/current")
    end

    it { expect { deployment.activate }.not_to raise_exception }
  end

  describe '#<=>' do
    subject { deployment == other }

    let(:other) { described_class.new(other_application, other_deployment_name) }

    context 'with the same application' do
      let(:other_application) { application }

      context 'with the same deployment name' do
        let(:other_deployment_name) { deployment_name }

        it { is_expected.to be_truthy }
      end

      context 'with another deployment name' do
        let(:other_deployment_name) { 'unrelated' }

        it { is_expected.to be_falsey }
      end
    end

    context 'with another application' do
      let(:other_application) { Application.new(title: 'app', name: 'another-instance-with-the-same-path', environment: 'production', path: path, deploy_user: Process.uid, deploy_group: Process.gid, user_mapping: user_mapping, group_mapping: group_mapping, retention_min: 5, retention_max: nil) }

      context 'with the same deployment name' do
        let(:other_deployment_name) { deployment_name }

        it { is_expected.to be_falsey }
      end

      context 'with another deployment name' do
        let(:other_deployment_name) { 'unrelated' }

        it { is_expected.to be_falsey }
      end
    end
  end

  context '#persistent_data_specifications' do
    subject { deployment.persistent_data_specifications }

    let(:user_mapping) do
      {
        'john' => 'jane',
      }
    end
    let(:group_mapping) do
      {
        'wheel' => 'root',
      }
    end

    before do
      parser = Mtree::Parser.new
      parser.parse(<<~MTREE)
      /set type=dir uname=root gname=wheel mode=0755
      . nochange
          tmp uname=john gname=john mode=0700
          ..
      ..
      MTREE
      allow(deployment).to receive(:persistent_data_specifications_load).and_return(parser.specifications)
    end

    it { is_expected.to have_attributes(uname: 'root', gname: 'root') }
    it 'is expected to have its first children to have attributes {:gname => "john", :uname => "jane"}' do
      expect(subject.children.first).to have_attributes(uname: 'jane', gname: 'john')
    end
  end

  context 'with deploy hooks' do
    subject { deployment.deploy(url) }

    let(:url) { double }

    before do
      artifact = double
      allow(Artifact).to receive(:new).with(url, {}).and_return(artifact)
      allow(artifact).to receive(:extract_to)
      allow(artifact).to receive(:unlink)
      allow(application).to receive(:setup_persistent_data)
      allow(application).to receive(:link_persistent_data)
      allow(deployment).to receive(:run_hook).with('before_deploy').and_call_original
      allow(deployment).to receive(:run_hook).with('after_deploy').and_call_original
    end

    it 'returns true when all hooks succeed' do
      allow(deployment).to receive(:hook_path).with('before_deploy').and_return(fixture('success_hook'))
      allow(deployment).to receive(:hook_path).with('after_deploy').and_return(fixture('success_hook'))

      expect { deployment.deploy(url, {}) }.not_to raise_exception
      expect(deployment).to have_received(:run_hook).with('before_deploy')
      expect(deployment).to have_received(:run_hook).with('after_deploy')
    end

    it 'raise when the before deployment hook fail' do
      allow(deployment).to receive(:hook_path).with('before_deploy').and_return(fixture('failure_hook'))
      allow(deployment).to receive(:hook_path).with('after_deploy').and_return(fixture('success_hook'))

      expect { deployment.deploy(url, {}) }.to raise_exception('Aborted deployment: before_deploy hook failed')
      expect(deployment).to have_received(:run_hook).with('before_deploy')
      expect(deployment).not_to have_received(:run_hook).with('after_deploy')
    end

    it 'return false when the after deployment hook fail' do
      allow(deployment).to receive(:hook_path).with('before_deploy').and_return(fixture('success_hook'))
      allow(deployment).to receive(:hook_path).with('after_deploy').and_return(fixture('failure_hook'))

      expect { deployment.deploy(url, {}) }.to raise_exception('after_deploy hook failed')
      expect(deployment).to have_received(:run_hook).with('before_deploy')
      expect(deployment).to have_received(:run_hook).with('after_deploy')
    end
  end
end
