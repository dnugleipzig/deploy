task ps_script_analyzer: [:paket] do
  next unless Rake::Win32.windows?

  analyzer = %w(
    powershell.exe
    -NoLogo
    -NonInteractive
    -NoProfile
    -ExecutionPolicy Bypass
    -Command
  )

  %w(lib).each do |path|
    command = <<-COMMAND
      & {
        Import-Module -Name ./packages/PSScriptAnalyzer/PSScriptAnalyzer;
        Invoke-ScriptAnalyzer -Path '#{path}'
          -Recurse
          -Profile ./.PSAnalyzer.ps1
      }
    COMMAND

    command = command.each_line.map(&:strip).join(' ')

    sh(*analyzer, command)
  end
end
