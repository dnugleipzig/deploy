# frozen_string_literal: true

source 'https://rubygems.org'

gem 'capistrano', '~> 3.7'
gem 'capistrano-scm-rsync'
gem 'inwx-rb', '~> 0.1'
gem 'rake-funnel', '~> 0.15pre'
# Required for inwx-rb.
install_if(-> { RUBY_VERSION >= '2.4' }) do
  gem 'xmlrpc', '~> 0.3'
end

group :test do
  gem 'rspec', '~> 3.4'
  gem 'rspec-teamcity'

  gem 'simplecov', '~> 0.11'
  gem 'simplecov-teamcity-summary', '~> 1.0'
end

group :style do
  gem 'rubocop', '!= 0.62'
  gem 'rubocop-checkstyle_formatter'
  gem 'rubocop-rspec'
end

group :development do
  gem 'awesome_print'
  gem 'pry-byebug'

  # guard.
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'guard-shell'

  # guard notifications.
  install_if(-> { Gem.win_platform? }) do
    gem 'ruby_gntp'
    gem 'wdm'
  end

  install_if(-> { RbConfig::CONFIG['target_os'] =~ /linux/i }) do
    gem 'rb-inotify'
  end

  install_if(-> { RbConfig::CONFIG['target_os'] =~ /mac|darwin/i }) do
    gem 'rb-fsevent'
    gem 'terminal-notifier-guard'
  end
end
