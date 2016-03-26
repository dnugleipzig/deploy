$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'Set-RootDirectory' {
  InModuleScope Deployment {
    Mock Out-Host
    Mock Set-Location

    Context 'path exists' {
      It 'changes to path' {
        Set-RootDirectory -Path '.'

        Assert-MockCalled Set-Location -ParameterFilter { $Path -eq (Convert-Path -Path '.') }
      }
    }

     Context 'path does not exist' {
      It 'fails' {
        { Set-RootDirectory -Path TestDrive:\does-not-exist } | Should Throw 'does-not-exist'
      }
    }
  }
}
