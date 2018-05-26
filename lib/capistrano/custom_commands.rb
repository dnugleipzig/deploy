# frozen_string_literal: true

require 'sshkit'

cmd = %w(
  powershell.exe
  -Version 4.0
  -NoLogo
  -NoProfile
  -NonInteractive
  -ExecutionPolicy Bypass
  -InputFormat None
  -Command
)

SSHKit.config.command_map[:powershell] = cmd.map(&:shellescape).join(' ')
