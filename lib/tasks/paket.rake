require 'rake/funnel'

Rake::Funnel::Tasks::Paket.new

task :paket do
  target = 'lib/powershell/PowerYaml'
  mkdir_p(target)

  cp %w(packages/YamlDotNet/lib/net35/YamlDotNet.dll paket-files/dfinke/PowerYaml/PowerYaml.psm1), target
end
