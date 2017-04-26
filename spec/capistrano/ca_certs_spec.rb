require 'capistrano/ca_certs'
require 'open-uri'

describe CACerts do
  before {
    allow(Rake::Win32).to receive(:windows?).and_return(windows)
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
    let(:cache?) { false }
    let(:cache_date) { Time.now }

    before {
      allow(described_class).to receive(:puts)
      allow(described_class).to receive(:open).and_yield(spy(IO))
      allow(FileUtils).to receive(:mkdir_p)
      allow(FileUtils).to receive(:cp)
      allow(File).to receive(:exist?).with(cache).and_return(cache?)
      allow(File).to receive(:mtime).with(cache).and_return(cache_date)
    }

    context 'cached copy is younger than one day' do
      let(:cache?) { true }

      before {
        described_class.path
      }

      it 'omits download' do
        expect(described_class).not_to have_received(:open)
      end

      it 'sets SSL_CERT_FILE environment variable' do
        expect(ENV).to have_received(:[]=).with('SSL_CERT_FILE', cache)
      end
    end

    context 'no cached copy' do
      let(:cache?) { false }

      before {
        described_class.path
      }

      it 'downloads' do
        expect(described_class).to have_received(:open)
      end

      it 'sets SSL_CERT_FILE environment variable' do
        expect(ENV).to have_received(:[]=).with('SSL_CERT_FILE', file)
      end

      it 'caches CA certs' do
        expect(FileUtils).to have_received(:cp).with(file, cache)
      end
    end

    context 'oudated cached copy' do
      let(:cache?) { true }
      let(:cache_date) { Time.at(0) }

      context 'download successful' do
        before {
          described_class.path
        }

        it 'downloads' do
          expect(described_class).to have_received(:open)
        end

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
end
