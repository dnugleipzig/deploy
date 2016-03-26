source 'https://rubygems.org'

gem 'capistrano', '~> 3.4'
gem 'rake-funnel', '~> 0.15pre'

group :lint do
  gem 'rubocop', '~> 0.37'
  gem 'rubocop-checkstyle_formatter'
end

group :development do
  gem 'pry-byebug'
  gem 'awesome_print'

  # guard.
  gem 'guard-bundler'
  gem 'guard-rubocop'
  gem 'guard-shell'

  gem 'wdm', '>= 0.1.0', require: false if Gem.win_platform?
  gem 'ruby_gntp'
end
