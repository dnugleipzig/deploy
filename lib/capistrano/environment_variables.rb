# frozen_string_literal: true

class EnvironmentVariables
  PREFIX = /^DEPLOY_ENV_/.freeze

  class << self
    def extract(where = {})
      where.keys
           .select { |key| key =~ PREFIX }
           .each_with_object({}) do |key, memo|
             memo[key.sub(PREFIX, '')] = where[key]
           end
    end
  end
end
