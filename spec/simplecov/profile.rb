require 'pathname'
require 'rake/funnel'
require 'simplecov'
require 'simplecov-teamcity-summary'
require_relative './teamcity_service_message_formatter'

module RSpec
  module SimpleCov
    module Profile
      ::SimpleCov.profiles.define(:default) do
        track_files('lib/**/*.rb')

        add_filter do |file|
          relative_path = Pathname.new(file.filename)
                                  .relative_path_from(Pathname.new(::SimpleCov.root))
          relative_path.to_s =~ %r{^spec/}
        end

        coverage_dir('build/coverage')

        format = [::SimpleCov::Formatter::HTMLFormatter]
        if Rake::Funnel::Integration::TeamCity.running?
          format << ::SimpleCov::Formatter::TeamcitySummaryFormatter
          format << TeamCityServiceMessageFormatter
        end

        formatter(::SimpleCov::Formatter::MultiFormatter.new(format))
      end
    end
  end
end
