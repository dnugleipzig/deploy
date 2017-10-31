require 'rake/funnel'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--order random --format html --out build/spec/rspec.html'
  t.rspec_opts += ' --format progress' unless Rake::Funnel::Integration::TeamCity.running?
  t.rspec_opts += ' ' + ENV['RSPEC_OPTS'] if ENV.include?('RSPEC_OPTS')
end

task spec: [:paket] do
  next unless Rake::Win32.windows?

  mkdir_p 'build/spec'

  pester = %w(
    powershell.exe
    -NoLogo
    -NonInteractive
    -NoProfile
    -ExecutionPolicy Bypass
    -Command
  )

  files = Dir['lib/**/*.ps1'].map { |f| "'#{f}'" }.join(', ')

  command = <<-COMMAND
    & {
      Import-Module -Name ./packages/Pester/tools/Pester;
      Invoke-Pester -Path 'spec'
        -EnableExit
        -OutputFile build/spec/pester.xml
        -OutputFormat NUnitXml
        -CodeCoverage #{files}
    }
  COMMAND

  command = command.each_line.map(&:strip).join(' ')
  pester << command
  sh(*pester)
end
