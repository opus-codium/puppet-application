# frozen_string_literal: true

require_relative '../../../../tasks/utils/artifact'

RSpec.describe Artifact do
  describe '#common_root' do
    subject { described_class.new.common_root(filenames) }

    context('with a single root file') do
      let(:filenames) do
        [
          'file_a',
        ]
      end

      it { is_expected.to be_nil }
    end

    context('with many root files') do
      let(:filenames) do
        %w[
          file_a
          file_b
        ]
      end

      it { is_expected.to be_nil }
    end

    context('with a common root') do
      let(:filenames) do
        [
          'root/',
          'root/subdirectory/',
          'root/subdirectory/file',
        ]
      end

      it { is_expected.to eq('root') }
    end

    context 'with root files and directories' do
      let(:filenames) do
        [
          'directory_a/',
          'directory_a/file_a',
          'directory_a/file_b',
          'directory_b/',
          'directory_b/file_c',
        ]
      end

      it { is_expected.to be_nil }
    end
  end
end
