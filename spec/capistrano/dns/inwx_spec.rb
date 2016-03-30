require 'capistrano/dns'

describe DNS::Inwx do
  let(:api_endpoint) { 'api.ote.domrobot.com' }
  let(:config) {
    {
      'user' => 'agross-ote',
      'password' => 'agross-ote123',
      'records' => records
    }
  }

  let!(:robot) {
    api = INWX::Domrobot.new(api_endpoint)
    allow(api).to receive(:call).and_call_original

    # Disallow updates.
    %w(createRecord updateRecord deleteRecord).each do |method|
      result = { 'code' => 1000 }

      allow(api).to receive(:call).with('nameserver', method, anything).and_return(result)
    end

    allow(INWX::Domrobot).to receive(:new).and_return(api)

    api
  }

  before {
    allow(subject).to receive(:warn)
    allow(subject).to receive(:puts)
    allow(CACerts).to receive(:puts)
  }

  subject {
    described_class.new(config, api_endpoint)
  }

  describe '#new' do
    context 'user and password with env:// token' do
      let(:config) {
        {
          'user' => 'env://USER',
          'password' => 'env://PASSWORD'
        }
      }

      subject {
        allow(ENV).to receive(:[]).with('USER').and_return('user from env')
        allow(ENV).to receive(:[]).with('PASSWORD').and_return('password from env')

        described_class.new(config, api_endpoint)
      }

      it 'retrieves user name from environment variables' do
        expect(subject.instance_variable_get(:@user)).to eq('user from env')
      end

      it 'retrieves password from environment variables' do
        expect(subject.instance_variable_get(:@password)).to eq('password from env')
      end
    end
  end

  describe '#run' do
    context 'domain is not registered with INWX account' do
      let(:records) {
        [
          {
            'type' => 'a',
            'name' => 'foo.example.com',
            'content' => '1.2.3.4'
          }
        ]
      }

      it 'fails' do
        expect { subject.run }.to raise_error('Domain example.com is not managed by this account')
      end
    end

    context 'domain is registered with INWX account' do
      before {
        subject.run
      }

      context 'record exists' do
        context 'with matching value' do
          let(:records) {
            [
              {
                'type' => 'a',
                'name' => 'exists-as-a.example-test.com',
                'content' => '1.2.3.4'
              }
            ]
          }

          it 'does not change record' do
            expect(robot).not_to have_received(:call).with('nameserver', 'createRecord', anything)
            expect(robot).not_to have_received(:call).with('nameserver', 'updateRecord', anything)
            expect(robot).not_to have_received(:call).with('nameserver', 'deleteRecord', anything)
          end
        end

        context 'with different value' do
          let(:records) {
            [
              {
                'type' => 'a',
                'name' => 'exists-as-a.example-test.com',
                'content' => '127.0.0.1'
              }
            ]
          }

          it 'updates record' do
            expect(robot).to have_received(:call).with('nameserver',
                                                       'updateRecord',
                                                       hash_including(
                                                         'id' => 28_994,
                                                         'type' => 'A',
                                                         'name' => 'exists-as-a',
                                                         'content' => '127.0.0.1'))
          end
        end

        context 'with different type' do
          let(:records) {
            [
              {
                'type' => 'a',
                'name' => 'exists-as-aaaa.example-test.com',
                'content' => '1.2.3.4'
              }
            ]
          }

          it 'creates record' do
            expect(robot).to have_received(:call).with('nameserver',
                                                       'createRecord',
                                                       hash_including(
                                                         'domain' => 'example-test.com',
                                                         'type' => 'A',
                                                         'name' => 'exists-as-aaaa',
                                                         'content' => '1.2.3.4'))
          end
        end
      end

      context 'record does not exist' do
        let(:records) {
          [
            {
              'type' => 'a',
              'name' => 'does-not.exist.example-test.com',
              'content' => '1.2.3.4'
            }
          ]
        }

        it 'creates record' do
          expect(robot).to have_received(:call).with('nameserver',
                                                     'createRecord',
                                                     hash_including(
                                                       'domain' => 'example-test.com',
                                                       'type' => 'A',
                                                       'name' => 'does-not.exist',
                                                       'content' => '1.2.3.4'))
        end
      end
    end
  end
end
