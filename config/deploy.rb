require 'rake/funnel'

STDOUT.sync = STDERR.sync = true

# Config valid only for current version of Capistrano.
lock '3.9.0'

set :format_options, log_file: 'build/log/capistrano.log'

set :ssh_options,
    user: 'capistrano',
    keys: %w(ssh/capistrano),
    auth_methods: %w(publickey)

set :rsh, "ssh -i #{fetch(:ssh_options)[:keys].first} -o PasswordAuthentication=no -o StrictHostKeyChecking=no"

set :rsync_options,
    source: 'app',
    cache: 'deploy',
    args: {
      local_to_remote: %W(--rsh #{fetch(:rsh)}
                          --progress
                          --compress
                          --recursive
                          --delete
                          --delete-excluded),
      cache_to_release: %w(--archive)
    }

set :manifest, YAML.load_file(File.join(fetch(:rsync_options)[:source],
                                        'deploy.yaml'))

set :deploy_root, ENV['DEPLOY_ROOT'] \
  || raise('Could not determine deployment root from DEPLOY_ROOT environment variable')
set :deploy_server, ENV['DEPLOY_SERVER'] \
  || raise('Could not determine server from DEPLOY_SERVER environment variable')

server fetch(:deploy_server), roles: %w(app)

set :application, fetch(:manifest)['application']['name']
set :deploy_to, File.join(fetch(:deploy_root), fetch(:stage).to_s, fetch(:application))

set :default_env, cygwin: 'winsymlinks:nativestrict'

set :linked_dirs, %w(tools/nuget tools/webpi)

before 'deploy:check', 'dns' do
  task('dns:setup').invoke(fetch(:manifest).fetch('application', {})['dns'])
end

after 'deploy:check:linked_dirs', 'download:tools' do
  task('download:webpi').invoke(File.join(shared_path, 'tools/webpi/WebpiCmd.exe'))
  task('download:nuget').invoke(File.join(shared_path, 'tools/nuget/nuget.exe'))
end

before 'deploy:new_release_path', 'copy:powershell'

before 'deploy:set_current_revision', 'publish:build_number' do
  require 'capistrano/version_reader'
  set :current_revision, VersionReader.read_from(fetch(:manifest))

  Rake::Funnel::Integration::TeamCity::ServiceMessages.build_number(fetch(:current_revision))
end

after 'deploy:updated', 'powershell:uninstall_previous'
after 'deploy:reverted', 'powershell:uninstall_previous'

before 'deploy:publishing', 'powershell:install_current'
after  'deploy:published', 'teamcity:publish_canonical_domain'
