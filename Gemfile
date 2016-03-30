source 'https://rubygems.org'

gem 'capistrano', '~> 3.4'
gem 'rake-funnel', '~> 0.15pre'
gem 'inwx-rb', '~> 0.1'

group :development do
  gem 'pry-byebug'
  gem 'awesome_print'

  # RuboCop.
  gem 'rubocop', '~> 0.37.2'
  gem 'rubocop-checkstyle_formatter'
  gem 'rubocop-rspec'

  # RSpec.
  gem 'rspec', '~> 3.4'
  gem 'simplecov', '~> 0.11'
  gem 'simplecov-teamcity-summary', '~> 0.1'

  # guard.
  gem 'guard-bundler'
  gem 'guard-rubocop'
  gem 'guard-shell'
  gem 'guard-rspec'

  gem 'wdm', '>= 0.1.0', require: false if Gem.win_platform?
  gem 'ruby_gntp'
end
