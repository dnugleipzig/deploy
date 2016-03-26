$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'Install-Packages' {
  InModuleScope Deployment {
    Mock Install-Package

    Context 'no packages' {
      Install-Packages -Config @{}

      It 'does not install packages' {
        Assert-MockCalled Install-Package -Exactly 0
      }
    }

    Context 'packages to install' {
      $Config = @{
        'latest' = $null
        'version' = @{
          version = '1.2.3'
        }
        'import' = @{
          import = 'lib/package.dll'
        }
        'imports' = @{
          import = @('lib/1.dll', 'lib/2.dll')
        }
        'version-and-import' = @{
          version = '4.5.6'
          import = 'lib/package.dll'
        }
      }

      Install-Packages -Config $Config

      It 'installs package with latest version' {
        Assert-MockCalled Install-Package -ParameterFilter {
          $Id -eq 'latest' -and
            $Version -eq $null -and
            $Import-eq $null
        }
      }

      It 'installs package with version' {
        Assert-MockCalled Install-Package -ParameterFilter {
          $Id -eq 'version' -and
            $Version -eq $Config.version.version -and
            $Import -eq $null
        }
      }

      It 'installs package with import' {
        Assert-MockCalled Install-Package -ParameterFilter {
          $Id -eq 'import' -and
            $Version -eq $null -and
            $Import -eq $Config.import.import
          }
      }

      It 'installs package with imports' {
        Assert-MockCalled Install-Package -ParameterFilter {
          $Id -eq 'imports' -and
            $Version -eq $null -and
            $Import -is [array] -and
            $Import[0] -eq $Config.imports.import[0] -and
            $Import[1] -eq $Config.imports.import[1]
        }
      }

      It 'installs package with version and import' {
        Assert-MockCalled Install-Package -ParameterFilter {
          $Id -eq 'version-and-import' -and
            $Version -eq $Config.'version-and-import'.version -and
            $Import -eq $Config.'version-and-import'.import
        }
      }
    }

    Context 'uninstall' {
      $Config = @{
        something = $null
      }

      Install-Packages -Config $Config -Uninstall

      It 'does not uninstall packages' {
        Assert-MockCalled Install-Package -Exactly 0
      }
    }
  }
}
