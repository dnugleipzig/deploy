require 'rake'

module CACerts
  class << self
    def path
      ENV['SSL_CERT_FILE'] = download.path if Rake::Win32.windows?
    end

    private

    def download
      require 'tempfile'
      require 'open-uri'
      require 'openssl'

      file = Tempfile.new(%w(ruby-cacerts .pem))

      puts "Downloading CA certs to #{file.path}"
      open('https://curl.haxx.se/ca/cacert.pem', ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        file.write(http.read)
      end

      file
    end
  end
end
