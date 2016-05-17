require 'rake'

module CACerts
  class << self
    def path
      ENV['SSL_CERT_FILE'] = download if Rake::Win32.windows?
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
      rescue => e
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

    def try_cached
      raise IOError, "CA certs cache file could not be found at #{cache}" unless File.exist?(cache)
      cache
    end
  end
end
