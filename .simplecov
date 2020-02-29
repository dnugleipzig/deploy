#!/usr/bin/env ruby

require 'pathname'
require 'rake/funnel'
require 'simplecov-teamcity-summary'
require_relative 'spec/support/simplecov/teamcity_service_message_formatter'

SimpleCov.start do
  track_files('lib/**/*.rb')

  add_filter do |file|
    relative_path = Pathname.new(file.filename)
                            .relative_path_from(Pathname.new(SimpleCov.root))
    relative_path.to_s =~ %r{^spec/}
  end

  Dir['lib/*']
    .select { |e| File.directory?(e) }
    .reject { |d| d == 'lib/tasks' }
    .each do |d|
      add_group File.basename(d), d
    end

  coverage_dir('build/coverage')

  format = [::SimpleCov::Formatter::HTMLFormatter]

  if Rake::Funnel::Integration::TeamCity.running?
    format << ::SimpleCov::Formatter::TeamcitySummaryFormatter
    format << Spec::Support::SimpleCov::TeamCityServiceMessageFormatter
  end

  formatter(::SimpleCov::Formatter::MultiFormatter.new(format))
end
