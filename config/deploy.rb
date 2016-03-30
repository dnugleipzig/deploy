require 'rake/funnel'

STDOUT.sync = STDERR.sync = true

# config valid only for current version of Capistrano
lock '3.4.0'

set :ssh_options,
    user: 'capistrano',
    keys: %w(ssh/capistrano),
    auth_methods: %w(publickey)

set :scm, :rsync
set :rsync_copy, %w(rsync --archive)
set :rsh, "ssh -i #{fetch(:ssh_options)[:keys].first} -o PasswordAuthentication=no -o StrictHostKeyChecking=no"
set :rsync_options, %W(--rsh #{fetch(:rsh)} --progress --compress --recursive --delete --delete-excluded)
set :rsync_stage, 'app'

set :manifest, YAML.load_file(File.join(fetch(:rsync_stage), 'deploy.yaml'))

set :deploy_root, ENV['DEPLOY_ROOT'] || raise('Could not determine deployment root from DEPLOY_ROOT environment variable')
set :deploy_server, ENV['DEPLOY_SERVER'] || raise('Could not determine server from DEPLOY_SERVER environment variable')

server fetch(:deploy_server), roles: %w(app)

set :application, fetch(:manifest)['application']['name']
set :deploy_to, File.join(fetch(:deploy_root), fetch(:stage).to_s, fetch(:application))

set :default_env, cygwin: 'winsymlinks:nativestrict'

set :linked_dirs, %w(tools)

before 'deploy:check', 'dns:setup' do
  DNS.setup(fetch(:manifest)['dns'])
end

after 'deploy:check:linked_dirs', 'download:tools' do
  task('download:webpi').invoke(File.join(shared_path, 'tools/webpi/WebpiCmd.exe'))
  task('download:nuget').invoke(File.join(shared_path, 'tools/nuget/nuget.exe'))
end

before :rsync, 'copy:powershell'

after 'deploy:set_current_revision', 'publish:build_number' do
  Rake::Funnel::Integration::TeamCity::ServiceMessages.build_number(fetch(:current_revision))
end

after 'deploy:updated', 'powershell:uninstall_previous'
after 'deploy:reverted', 'powershell:uninstall_previous'

before 'deploy:publishing', 'powershell:install_current'
