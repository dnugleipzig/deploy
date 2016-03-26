task spec: [:paket] do
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

  command = <<-EOF
    & {
      Import-Module -Name ./packages/Pester/Pester;
      Invoke-Pester -Path 'spec'
        -EnableExit
        -OutputFile build/spec/pester.xml
        -OutputFormat NUnitXml
        -CodeCoverage #{files}
    }
  EOF

  command = command.each_line.map(&:strip).join(' ')
  pester << command
  sh(*pester)
end
