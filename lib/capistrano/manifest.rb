require 'json'

class Manifest
  class << self
    def read_from(file)
      JSON.parse(File.read(file))
    end
  end
end
