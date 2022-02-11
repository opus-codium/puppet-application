# frozen_string_literal: true

require 'spec_helper'

describe 'application::kind' do
  let(:title) { 'rails' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'without parameters' do
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
