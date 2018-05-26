# frozen_string_literal: true

require 'capistrano/dns'

describe DNS do
  describe '#setup' do
    context 'no DNS configuration' do
      it 'succeeds' do
        described_class.setup(nil)
      end
    end

    context 'no records' do
      let(:config) do
        {
          inwx:
          {
            username: 'user name',
            password: 'password',
            records: []
          }
        }
      end

      it 'succeeds' do
        described_class.setup(config)
      end
    end

    context 'records' do
      let(:config) do
        {
          inwx:
          {
            username: 'user name',
            password: 'password',
            records: [
              {
                type: 'a',
                name: 'foo.example.com',
                value: '1.2.3.4'
              }
            ]
          },
          another_provider:
          {
            username: 'user name',
            password: 'password',
            records: [
              {
                type: 'a',
                name: 'bar.example.com',
                value: '1.2.3.4'
              }
            ]
          }
        }
      end

      class AnotherProvider
        def initialize(config); end

        def run; end
      end

      before do
        allow(described_class).to receive(:download_cacerts)
        allow(DNS::Inwx).to receive(:new).and_return(double(DNS::Inwx).as_null_object)
        allow(AnotherProvider).to receive(:new).and_return(double(AnotherProvider).as_null_object)

        described_class.setup(config)
      end

      it 'creates first adapter' do
        expect(DNS::Inwx).to have_received(:new).with(config[:inwx])
      end

      it 'runs first adapter' do
        expect(DNS::Inwx.new(nil)).to have_received(:run)
      end

      it 'creates second adapter' do
        expect(AnotherProvider).to have_received(:new).with(config[:another_provider])
      end

      it 'runs second adapter' do
        expect(AnotherProvider.new(nil)).to have_received(:run)
      end
    end
  end
end
