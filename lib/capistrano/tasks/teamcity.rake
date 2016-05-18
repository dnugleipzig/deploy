require 'rake/funnel'

namespace :teamcity do
  task :publish_canonical_domain do
    canonical = fetch(:manifest).fetch('application', {})
                                .fetch('dns', {})
                                .fetch('inwx', {})
                                .fetch('records', []).first || {}

    next unless canonical.key?('name')

    Rake::Funnel::Integration::TeamCity::ServiceMessages.build_status(text: "{build.status.text}, Deployed to #{canonical['name']}")
  end
end
