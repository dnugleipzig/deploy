rsync_cache = lambda do
  cache = fetch(:rsync_cache)
  cache = File.join(deploy_to, cache) if cache && cache !~ %r{^/}
  cache
end

desc 'Stage and rsync to the server (or its cache).'
task :rsync do
  on release_roles(:all) do |role|
    user = if role.user
             role.user
           elsif fetch(:ssh_options)[:user]
             fetch(:ssh_options)[:user]
           end

    user = "#{user}@" unless user.nil?

    rsync = %w(rsync)
    rsync.concat fetch(:rsync_options)
    rsync << File.join(fetch(:rsync_stage), '/')
    rsync << "#{user}#{role.hostname}:#{rsync_cache.call || release_path}"

    RakeFileUtils.sh(*rsync)
  end
end

namespace :load do
  task :defaults do
    set :rsync_options, []
    set :rsync_copy, %w(rsync --archive --acls --xattrs)

    # Stage is used on your local machine for rsyncing from.
    set :rsync_stage, 'tmp/deploy'

    # Cache is used on the server to copy files to from to the release directory.
    # Saves you rsyncing your whole app folder each time.  If you nil rsync_cache,
    # Capistrano::Rsync will sync straight to the release path.
    set :rsync_cache, 'shared/deploy'
  end
end

namespace :rsync do
  task :check do
    # No-op.
  end

  desc 'Copy the code to the releases directory.'
  task release: [:rsync] do
    # Skip copying if we've already synced straight to the release directory.
    next unless fetch(:rsync_cache)

    copy = [
      fetch(:rsync_copy),
      File.join(rsync_cache.call, '/').shellescape,
      File.join(release_path, '/').shellescape
    ].flatten

    on release_roles(:all) do
      execute(*copy)
    end
  end

  # Matches the naming scheme of git tasks.
  task create_release: [:release]

  desc 'Determine the deployed revision'
  task :set_current_revision do
    set :current_revision, Time.now
  end
end
