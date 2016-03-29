require 'rake/funnel'

class VersionReader
  class << self
    def read_from(hash = {})
      version = (hash || {}).fetch('application', {}).fetch('version', {})

      explicit(version) || from_binary(version) || now
    end

    private

    def explicit(value)
      value unless value.is_a?(Hash)
    end

    def from_binary(value)
      return unless value.is_a?(Hash) && value['from']

      file = File.join(fetch(:rsync_stage), value['from'])
      read_version_from(file)
    end

    def read_version_from(file)
      Rake::Funnel::Support::BinaryVersionReader.read_from(file).file_version
    rescue => e
      raise e, "Could not read version from #{file}"
    end

    def now
      warn('Manifest requires a version, but no version could be found. Using current time.')
      Time.now
    end
  end
end
