cmd = %w(
  powershell.exe
  -Version 4.0
  -NoLogo
  -NoProfile
  -NonInteractive
  -ExecutionPolicy Unrestricted
  -InputFormat None
  -Command
)

SSHKit.config.command_map[:powershell] = cmd.map(&:shellescape).join(' ')
