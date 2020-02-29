# frozen_string_literal: true

# Load DSL and set up stages.
require 'capistrano/setup'

# Include default deployment tasks.
require 'capistrano/deploy'

require 'capistrano/scm/rsync'
install_plugin Capistrano::SCM::Rsync

# Load custom tasks from `lib/capistrano/tasks` if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

# Prepend lib dir to LOAD_PATH.
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'capistrano/custom_commands'
require 'capistrano/dns'
require 'capistrano/environment_variables'
require 'capistrano/version'
