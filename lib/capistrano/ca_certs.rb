require 'rake'

module CACerts
  class << self
    SECONDS_PER_DAY = 86_400

    def path
      ENV['SSL_CERT_FILE'] = prefer_cached || download if Rake::Win32.windows?
    end

    private

    def download # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      require 'open-uri'
      require 'openssl'

      puts "Downloading CA certs to #{file.path}"
      begin
        open('https://curl.haxx.se/ca/cacert.pem', ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          file.write(http.read)
        end

        FileUtils.mkdir_p(File.dirname(cache))
        FileUtils.cp(file.path, cache)

        file.path
      rescue => e # rubocop:disable Style/RescueStandardError
        warn "Failed to download CA certs: #{e}"
        try_cached
      end
    end

    def file
      require 'tempfile'

      @file ||= Tempfile.new(%w(ruby-cacerts .pem))
    end

    def cache
      File.expand_path('.cache/ruby-cacerts.pem')
    end

    def prefer_cached
      cache if File.exist?(cache) && File.mtime(cache) > Time.at(Time.now.to_i - SECONDS_PER_DAY)
    end

    def try_cached
      raise IOError, "CA certs cache file could not be found at #{cache}" unless File.exist?(cache)
      cache
    end
  end
end
