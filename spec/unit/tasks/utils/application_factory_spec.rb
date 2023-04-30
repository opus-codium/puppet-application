# frozen_string_literal: true

require_relative '../../../../tasks/utils/application_factory'

RSpec.describe ApplicationFactory do
  describe '::find' do
    subject { described_class.find('app1', 'production') }

    before do
      allow(Application).to receive(:new).and_return(double)
    end

    context 'application is configured' do
      before do
        allow(described_class).to receive(:load_configuration_metadata).and_return([
                                                                                     {
                                                                                       'title'       => 'foo',
                                                                                       'application' => 'app1',
                                                                                       'environment' => 'production',
                                                                                     },
                                                                                     {
                                                                                       'title'       => 'bar',
                                                                                       'application' => 'app1',
                                                                                       'environment' => 'development',
                                                                                     },
                                                                                     {
                                                                                       'title'       => 'baz',
                                                                                       'application' => 'app2',
                                                                                       'environment' => 'development',
                                                                                     },
                                                                                     {
                                                                                       'title'       => 'qux',
                                                                                       'application' => 'app1',
                                                                                       'environment' => 'production',
                                                                                     },
                                                                                   ])
      end

      it { is_expected.to be_an(Array) }
      it { is_expected.to have_attributes(size: 2) }
    end

    context 'no application is configured' do
      before do
        allow(described_class).to receive(:load_configuration_metadata).and_return([])
      end

      it { expect { subject }.to raise_error('No match for application app1 in environment production') }
    end
  end
end
