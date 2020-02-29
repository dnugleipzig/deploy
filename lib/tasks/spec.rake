# frozen_string_literal: true

require 'rake/funnel'
require 'rspec/core/rake_task'

desc 'Run tests'
task :spec do
  rspec = RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = '--order random --format html --out build/spec/rspec.html'
    t.rspec_opts += ' --format progress' unless Rake::Funnel::Integration::TeamCity.running?
  end

  begin
    Rake::Task[rspec.name].execute
  ensure
    [
      'build/spec/**/* => spec',
      'build/coverage/**/* => coverage'
    ].each do |artifact|
      Rake::Funnel::Integration::TeamCity::ServiceMessages
        .publish_artifacts(artifact)
    end
  end
end

task spec: [:paket] do # rubocop:disable Metrics/BlockLength
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

  begin
    sh(*pester)
  ensure
    Rake::Funnel::Integration::TeamCity::ServiceMessages
      .import_data(type: :nunit,
                   path: 'build/spec/pester.xml')
  end
end
