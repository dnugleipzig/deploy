require 'capistrano/ca_certs'
require 'open-uri'

describe CACerts do
  before {
    allow(Rake::Win32).to receive(:windows?).and_return(windows)
  }

  before {
    allow(ENV).to receive(:[]=)
  }

  context 'not on Windows' do
    let(:windows) { false }

    before {
      described_class.path
    }

    it 'does not set SSL_CERT_FILE environment variable' do
      expect(ENV).not_to have_received(:[]=)
    end
  end

  context 'on Windows' do
    let(:windows) { true }
    let(:file) { described_class.send(:file).path }
    let(:cache) { described_class.send(:cache) }

    before {
      allow(described_class).to receive(:puts)
      allow(FileUtils).to receive(:cp)
    }

    context 'download successful' do
      before {
        described_class.path
      }

      it 'sets SSL_CERT_FILE environment variable' do
        expect(ENV).to have_received(:[]=).with('SSL_CERT_FILE', file)
      end

      it 'caches CA certs' do
        expect(FileUtils).to have_received(:cp).with(file, cache)
      end
    end

    context 'download fails' do
      before {
        allow(described_class).to receive(:warn)
        allow(described_class).to receive(:open).and_raise(Net::ReadTimeout.new)
      }

      describe 'cached copy' do
        before {
          allow(File).to receive(:exist?).with(cache).and_return(cache?)
        }

        context 'available' do
          let(:cache?) { true }

          before {
            described_class.path
          }

          it 'sets SSL_CERT_FILE environment variable' do
            expect(ENV).to have_received(:[]=).with('SSL_CERT_FILE', cache)
          end
        end

        context 'unavailable' do
          let(:cache?) { false }

          it 'fails' do
            expect { described_class.path }.to raise_error(IOError)
          end
        end
      end
    end
  end
end
