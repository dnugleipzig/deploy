# frozen_string_literal: true

require 'rake/funnel'
require 'uri'

namespace :teamcity do
  task :publish_canonical_domain do
    def web
      canonical = fetch(:manifest).fetch('deployment', [])
                                  .find(-> { {} }) { |e| e.key?('web') }
                                  .fetch('web', {})
                                  .fetch('bindings', [])
                                  .first

      return nil unless canonical &&
                        canonical.key?('protocol') &&
                        canonical.key?('host_header')

      URI::Generic.build(scheme: canonical['protocol'], host: canonical['host_header'])
    end

    def dns
      canonical = fetch(:manifest).fetch('application', {})
                                  .fetch('dns', {})
                                  .fetch('inwx', {})
                                  .fetch('records', [])
                                  .first

      return nil unless canonical && canonical.key?('name')

      canonical['name']
    end

    value = web || dns
    next unless value

    Rake::Funnel::Integration::TeamCity::ServiceMessages.build_status(text: "{build.status.text}, Deployed to #{value}")
  end
end
