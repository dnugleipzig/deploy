# frozen_string_literal: true

require 'capistrano/version_reader'

describe VersionReader do
  before do
    allow(described_class).to receive(:warn)
  end

  context 'no manifest' do
    let(:hash) { nil }

    before do
      allow(Time).to receive(:now).and_return(:now)
    end

    it 'yields current time' do
      expect(described_class.read_from(nil)).to eq(:now)
    end
  end

  context 'no version in manifest' do
    let(:hash) { {} }

    before do
      allow(Time).to receive(:now).and_return(:now)
    end

    it 'yields current time' do
      expect(described_class.read_from({})).to eq(:now)
    end
  end

  context 'version in manifest' do
    let(:hash) do
      { 'application' => { 'version' => '1.2.3' } }
    end

    it 'yields version' do
      expect(described_class.read_from(hash)).to eq('1.2.3')
    end
  end

  context 'version from file in manifest' do
    let(:hash) do
      { 'application' => { 'version' => { 'from' => 'binary.dll' } } }
    end

    before do
      allow(described_class).to receive(:fetch).with(:rsync_options).and_return(source: 'app')
      allow(Rake::Funnel::Support::BinaryVersionReader).to \
        receive(:read_from).and_return(OpenStruct.new(file_version: '4.5.6'))
    end

    it 'yields version from binary' do
      expect(described_class.read_from(hash)).to eq('4.5.6')
    end
  end

  context 'version from file in manifest fails' do
    let(:hash) do
      { 'application' => { 'version' => { 'from' => 'binary.dll' } } }
    end

    before do
      allow(described_class).to receive(:fetch).with(:rsync_options).and_return(source: 'app')
      allow(Rake::Funnel::Support::BinaryVersionReader).to \
        receive(:read_from).and_raise('read error')
    end

    it 'fails' do
      expect { described_class.read_from(hash) }.to raise_error('Could not read version from app/binary.dll')
    end
  end
end
