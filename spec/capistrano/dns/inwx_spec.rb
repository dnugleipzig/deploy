require 'capistrano/dns'
require 'capistrano/ca_certs'

describe DNS::Inwx do
  subject do
    allow(INWX::Domrobot).to receive(:new).and_return(robot)
    described_class.new(config, api_endpoint)
  end

  let(:tld) { 'example.com' }
  let(:exists) do
    {
      a: {
        domain: tld,
        type: 'A',
        name: 'exists-as-a',
        content: '1.2.3.4'
      },
      aaaa: {
        domain: tld,
        type: 'AAAA',
        name: 'exists-as-aaaa',
        content: '::1'
      }
    }
  end

  let(:api_endpoint) { 'api.ote.domrobot.com' }
  let(:username) { 'agross-ote' }
  let(:password) { 'agross-ote123' }
  let(:config) do
    {
      'username' => username,
      'password' => password,
      'records' => records
    }
  end

  let(:robot) do
    api = INWX::Domrobot.new(api_endpoint)

    %i(login logout call).each do |method|
      allow(api).to receive(method).and_call_original
    end

    # Disallow updates.
    %w(createRecord updateRecord deleteRecord).each do |method|
      result = { 'code' => 1000 }

      allow(api).to receive(:call).with('nameserver', method, anything).and_return(result)
    end

    api
  end

  def prime_inwx_test_account # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    allow(CACerts).to receive(:puts)

    primer = INWX::Domrobot.new(api_endpoint)
    primer.client.http.ca_file = CACerts.path

    begin
      result = primer.login(username, password)
      expect(result).to include('code' => 1000)

      result = primer.call('nameserver',
                           'create',
                           domain: tld,
                           type: :MASTER,
                           ns: %w(ns.ote.inwx.de ns2.ote.inwx.de))
      expect(result).to include('code' => 1000).or include('code' => 2302)

      exists.each do |type, record|
        result = primer.call('nameserver', 'info', record)
        expect(result).to include('code' => 1000)
        if result['resData'].key?('record')
          exists[type][:id] = result['resData']['record'].first['id']
          next
        end

        result = primer.call('nameserver', 'createRecord', record)
        expect(result).to include('code' => 1000)
        exists[type][:id] = result['resData']['id']
      end
    ensure
      primer.logout
    end
  end

  before do
    prime_inwx_test_account

    allow(subject).to receive(:warn)
    allow(subject).to receive(:puts)
    allow(CACerts).to receive(:puts)
  end

  describe '#new' do
    context 'user and password with env:// token' do
      subject do
        allow(ENV).to receive(:[]).with('USER').and_return('user from env')
        allow(ENV).to receive(:[]).with('PASSWORD').and_return('password from env')

        allow(INWX::Domrobot).to receive(:new).and_return(robot)
        described_class.new(config, api_endpoint)
      end

      let(:config) do
        {
          'username' => 'env://USER',
          'password' => 'env://PASSWORD'
        }
      end

      it 'retrieves user name from environment variables' do
        expect(subject.instance_variable_get(:@username)).to eq('user from env')
      end

      it 'retrieves password from environment variables' do
        expect(subject.instance_variable_get(:@password)).to eq('password from env')
      end
    end
  end

  describe '#run' do
    describe 'login and logout' do
      context 'no records' do
        let(:records) { [] }

        before do
          subject.run
        end

        it 'does not log in' do
          expect(robot).not_to have_received(:login)
        end

        it 'does not log out' do
          expect(robot).not_to have_received(:logout)
        end
      end

      context 'some records' do
        let(:records) do
          [
            {
              'type' => 'a',
              'name' => "something.#{tld}",
              'content' => '1.2.3.4'
            }
          ]
        end

        before do
          subject.run
        end

        it 'logs in' do
          expect(robot).to have_received(:login)
        end

        it 'logs out' do
          expect(robot).to have_received(:logout)
        end
      end

      context 'record updates fail' do
        let(:records) do
          [
            {
              'type' => 'a',
              'name' => "creating-this-fails.#{tld}",
              'content' => '1.2.3.4'
            }
          ]
        end

        before do
          allow(robot).to receive(:call).with('nameserver', anything, anything).and_raise 'some error'

          subject.run rescue nil # rubocop:disable Style/RescueModifier
        end

        it 'logs in' do
          expect(robot).to have_received(:login)
        end

        it 'logs out' do
          expect(robot).to have_received(:logout)
        end
      end
    end

    context 'domain is not registered with INWX account' do
      let(:records) do
        [
          {
            'type' => 'a',
            'name' => 'foo.not-our-domain.com',
            'content' => '1.2.3.4'
          }
        ]
      end

      it 'fails' do
        expect { subject.run }.to raise_error(/^Domain not-our-domain.com is not managed by this account:/)
      end
    end

    context 'domain is registered with INWX account' do
      before do
        subject.run
      end

      context 'record exists' do
        context 'with matching value' do
          let(:records) do
            [
              {
                'type' => 'a',
                'name' => "#{exists[:a][:name]}.#{tld}",
                'content' => '1.2.3.4'
              }
            ]
          end

          it 'does not change record' do # rubocop:disable RSpec/MultipleExpectations
            expect(robot).not_to have_received(:call).with('nameserver', 'createRecord', anything)
            expect(robot).not_to have_received(:call).with('nameserver', 'updateRecord', anything)
            expect(robot).not_to have_received(:call).with('nameserver', 'deleteRecord', anything)
          end
        end

        context 'with different value' do
          let(:records) do
            [
              {
                'type' => 'a',
                'name' => "#{exists[:a][:name]}.#{tld}",
                'content' => '127.0.0.1'
              }
            ]
          end

          it 'updates record' do
            expect(robot).to have_received(:call).with('nameserver',
                                                       'updateRecord',
                                                       hash_including('id' => exists[:a][:id],
                                                                      'type' => 'A',
                                                                      'name' => exists[:a][:name],
                                                                      'content' => '127.0.0.1'))
          end
        end

        context 'with different type' do
          let(:records) do
            [
              {
                'type' => 'a',
                'name' => "#{exists[:aaaa][:name]}.#{tld}",
                'content' => '1.2.3.4'
              }
            ]
          end

          it 'creates record' do
            expect(robot).to have_received(:call).with('nameserver',
                                                       'createRecord',
                                                       hash_including('domain' => tld,
                                                                      'type' => 'A',
                                                                      'name' => exists[:aaaa][:name],
                                                                      'content' => '1.2.3.4'))
          end
        end
      end

      context 'record does not exist' do
        context 'without name' do
          let(:records) do
            [
              {
                'type' => 'a',
                'name' => tld,
                'content' => '1.2.3.4'
              }
            ]
          end

          it 'creates record' do
            expect(robot).to have_received(:call).with('nameserver',
                                                       'createRecord',
                                                       hash_including('domain' => tld,
                                                                      'type' => 'A',
                                                                      'name' => '',
                                                                      'content' => '1.2.3.4'))
          end
        end

        context 'subdomain' do
          let(:records) do
            [
              {
                'type' => 'a',
                'name' => "does-not.exist.#{tld}",
                'content' => '1.2.3.4'
              }
            ]
          end

          it 'creates record' do
            expect(robot).to have_received(:call).with('nameserver',
                                                       'createRecord',
                                                       hash_including('domain' => tld,
                                                                      'type' => 'A',
                                                                      'name' => 'does-not.exist',
                                                                      'content' => '1.2.3.4'))
          end
        end
      end
    end
  end
end
