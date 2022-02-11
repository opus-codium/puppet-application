# frozen_string_literal: true

require 'spec_helper'

describe 'application' do
  let(:title) { '/opt/acme' }
  let(:params) do
    {
      application: 'acme',
      environment: 'production',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      it { is_expected.to compile.with_all_deps }
    end
  end
end
