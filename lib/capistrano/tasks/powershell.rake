namespace :copy do
  desc 'Copy PowerShell library to application'
  task :powershell do
    target = File.join(fetch(:rsync_stage), 'lib')

    rm_rf(target)
    cp_r('lib/powershell/deployment/', target)
  end

  task :powershell do
    target = fetch(:rsync_stage)

    cp('lib/powershell/deploy.ps1', target)
  end
end

namespace :powershell do
  task :install_current do
    on release_roles(:all) do
      within(release_path) do
        with EnvironmentVariables.extract(ENV) do
          execute :powershell, './deploy.ps1'.shellescape, 'Install'.shellescape
        end
      end
    end
  end

  task :uninstall_previous do
    on release_roles(:all) do
      next unless test("[ -f #{File.join(current_path, 'deploy.ps1').shellescape} ]")

      within(current_path) do
        with EnvironmentVariables.extract(ENV) do
          execute :powershell, './deploy.ps1'.shellescape, 'Uninstall'.shellescape
        end
      end
    end
  end
end
