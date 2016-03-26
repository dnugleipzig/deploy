$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'Install-Requirements' {
  InModuleScope Deployment {
    Mock Exec

    Context 'no requirements' {
      Install-Requirements -Config @()

      It 'does not install requirements' {
        Assert-MockCalled Exec -Exactly 0
      }
    }

    Context 'requirements to install' {
      $Config = @(1, 2)

      Install-Requirements -Config $Config

      It 'executes Web Platform installer once' {
        Assert-MockCalled Exec -Exactly 1 -ParameterFilter { $Command -match 'WebpiCmd.exe' }
      }
    }

    Context 'uninstall' {
      $Config = @(1, 2)

      Install-Requirements -Config $Config -Uninstall

      It 'does not uninstall requirements' {
        Assert-MockCalled Exec -Exactly 0
      }
    }
  }
}
