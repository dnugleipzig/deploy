require 'simplecov'
require 'rspec/teamcity'

RSpec.configure do |config|
  config.add_formatter(Spec::Runner::Formatter::TeamcityFormatter) if Rake::Funnel::Integration::TeamCity.running?

  config.filter_run_when_matching(:focus)

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end
