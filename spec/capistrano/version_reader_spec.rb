require 'capistrano/version_reader'

describe VersionReader do
  before {
    allow(described_class).to receive(:warn)
  }

  context 'no manifest' do
    let(:hash) { nil }

    before {
      allow(Time).to receive(:now).and_return(:now)
    }

    it 'yields current time' do
      expect(described_class.read_from(nil)).to eq(:now)
    end
  end

  context 'no version in manifest' do
    let(:hash) { {} }

    before {
      allow(Time).to receive(:now).and_return(:now)
    }

    it 'yields current time' do
      expect(described_class.read_from({})).to eq(:now)
    end
  end

  context 'version in manifest' do
    let(:hash) {
      { 'application' => { 'version' => '1.2.3' } }
    }

    it 'yields version' do
      expect(described_class.read_from(hash)).to eq('1.2.3')
    end
  end

  context 'version from file in manifest' do
    let(:hash) {
      { 'application' => { 'version' => { 'from' => 'binary.dll' } } }
    }

    before {
      allow(described_class).to receive(:fetch).with(:rsync_stage).and_return('app')
      allow(Rake::Funnel::Support::BinaryVersionReader).to \
        receive(:read_from).and_return(OpenStruct.new(file_version: '4.5.6'))
    }

    it 'yields version from binary' do
      expect(described_class.read_from(hash)).to eq('4.5.6')
    end
  end

  context 'version from file in manifest fails' do
    let(:hash) {
      { 'application' => { 'version' => { 'from' => 'binary.dll' } } }
    }

    before {
      allow(described_class).to receive(:fetch).with(:rsync_stage).and_return('app')
      allow(Rake::Funnel::Support::BinaryVersionReader).to \
        receive(:read_from).and_raise('read error')
    }

    it 'fails' do
      expect { described_class.read_from(hash) }.to raise_error('Could not read version from app/binary.dll')
    end
  end
end
