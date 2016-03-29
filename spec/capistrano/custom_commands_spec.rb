require 'capistrano/custom_commands'

describe 'command map' do # rubocop:disable RSpec/DescribeClass
  it 'adds PowerShell command map' do
    expect(SSHKit.config.command_map[:powershell]).to be
  end

  it 'defines PowerShell invocation' do
    expect(SSHKit.config.command_map[:powershell]).to eq('powershell.exe -Version 4.0 -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -InputFormat None -Command')
  end
end
