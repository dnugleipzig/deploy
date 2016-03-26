$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'Install-Custom' {
  InModuleScope Deployment {
    New-Module -Name Deployment -ScriptBlock {
      function Install-Script {
        param(
          $Config
        )
      }

      function Uninstall-Script {
        param(
          $Config
        )
      }
    }

    $Config = @{
      install = 'Install-Script'
      uninstall = 'Uninstall-Script'
    }

    Mock -Module Deployment Out-Host

    Context 'install' {
      Mock -Module Deployment Convert-Path { $File }
      Mock -Module Deployment Test-Path { true }
      Mock -Module Deployment Install-Script

      Install-Custom -Config $Config

      It 'runs install script' {
        Assert-MockCalled -Module Deployment Install-Script
      }

      It 'passes config to script' {
         Assert-MockCalled -Module Deployment Install-Script -ParameterFilter { $Config.install -eq 'Install-Script' }
      }
    }

    Context 'uninstall' {
      Mock -Module Deployment Convert-Path { $File }
      Mock -Module Deployment Test-Path { true }
      Mock -Module Deployment Uninstall-Script

      Install-Custom -Uninstall -Config $Config

      It 'runs uninstall script' {
        Assert-MockCalled -Module Deployment Uninstall-Script
      }

      It 'passes config to script' {
        Assert-MockCalled -Module Deployment Uninstall-Script -ParameterFilter { $Config.install -eq 'Install-Script' }
      }
    }

    Context 'scripts do not exist' {
      $Config = @{
        install = 'TestDrive:\does-not-exist'
        uninstall = 'TestDrive:\does-not-exist'
      }

      It 'fails installation' {
        { Install-Custom -Config $Config } | Should Throw 'Cannot find path'
      }

      It 'fails uninstallation' {
       { Install-Custom -Uninstall -Config $Config } | Should Throw 'Cannot find path'
      }
    }

    Context 'scripts are not files' {
      $Config = @{
        install = 'TestDrive:\a-directory'
        uninstall = 'TestDrive:\a-directory'
      }

      New-Item -ItemType Directory -Path TestDrive:\a-directory

      It 'fails installation' {
        { Install-Custom -Config $Config } | Should Throw 'is not a file'
      }

      It 'fails uninstallation' {
       { Install-Custom -Uninstall -Config $Config } | Should Throw 'is not a file'
      }
    }

    Context 'scripts are not defined' {
      $Config = @{ }

      It 'does not fail installation' {
        Install-Custom -Config $Config
      }

      It 'does not fail uninstallation' {
        Install-Custom -Uninstall -Config $Config
      }
    }
  }
}
