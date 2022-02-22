# frozen_string_literal: true

require 'spec_helper'

require_relative '../../../../tasks/utils/application'
require_relative '../../../../tasks/utils/deployment'

RSpec.describe Deployment do
  subject(:deployment) { described_class.new(application, deployment_name) }

  let(:application) { Application.new(name: 'app', path: path) }
  let(:deployment_name) { '12345678' }

  let(:path) { Dir.mktmpdir }

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

  describe '#created_at' do
    subject { deployment.created_at }

    let(:ctime) { double }
    let(:stat) do
      stat = double
      allow(stat).to receive(:ctime).and_return(ctime)
      stat
    end

    before do
      allow(File).to receive(:stat).with("#{path}/12345678").and_return(stat)
    end

    it { is_expected.to eq(ctime) }
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
      let(:other_application) { Application.new(name: 'another-instance-with-the-same-path', path: path) }

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
end
