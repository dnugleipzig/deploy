require 'rake/funnel'

task :paket

unless ENV.include?('TRAVIS')
  Rake::Funnel::Tasks::Paket.new

  task :paket do
    target = 'lib/powershell/Deployment/lib'
    mkdir_p(target)

    cp(%w(packages/YamlDotNet/lib/net35/YamlDotNet.dll), target)
  end
end
