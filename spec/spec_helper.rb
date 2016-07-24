require 'simplecov'

RSpec.configure do |config|
  config.filter_run_when_matching(:focus)

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end
