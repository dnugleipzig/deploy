# frozen_string_literal: true

require 'rake/funnel'
require 'capistrano/dns/inwx'

module DNS
  class << self
    def setup(config)
      return if config.nil?

      config.each do |key, value|
        constantize(key).new(value).run
      end
    end

    private

    def constantize(value)
      const_get(value.pascalize)
    end
  end
end
