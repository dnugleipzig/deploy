require 'simplecov/profile'
require 'simplecov/teamcity_service_message_formatter'

SimpleCov.start(:default)

RSpec.configure do |config|
  config.filter_run_when_matching(:focus)

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end
