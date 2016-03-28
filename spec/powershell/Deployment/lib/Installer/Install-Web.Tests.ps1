$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'Install-Web' {
  InModuleScope Deployment {
    Mock New-RecreatedWebAppPool { @{ Name = $Name } }
    Mock New-RecreatedWebSite { @{ Name = $Name } }
    Mock Install-WebBindings
    Mock Start-Website
    Mock Test-HttpResponse

    Context 'install' {
      $Config = @{
        name = 'web site'
        physical_path = 'bin'
        properties = @{
          id = 42
          log_file = @{
            directory = 'absolute-path://../../logs2'
            log_ext_file_flags = 'Date,Time'
          }
        }
        app_pool = @{
          name = 'Application Pool'
          properties = @{
            identity = 'NetworkService'
            runtime = 'v4.0'
          }
        }
        bindings = @(
          @{
            protocol = 'http'
            host_header = 'example.com'
          },
          @{
            protocol = 'https'
            host_header = 'example.com'
          }
        )
        tests = @(
          @{
            method = 'GET'
            url = 'http://example.com/'
            expect = @{
              status = 200
              url = 'http://example.com/'
            }
          },
          @{
            method = 'GET'
            url = 'https://example.com/'
            expect = @{
              status = 200
              url = 'https://example.com/'
            }
          }
        )
      }

      Install-Web -Config $Config

      It 'creates the application pool' {
        Assert-MockCalled New-RecreatedWebAppPool -ParameterFilter {
          $Name -eq $Config.app_pool.name -and
          $Identity -eq $Config.app_pool.identity -and
          $Runtime -eq $Config.app_pool.runtime
        }
      }

      It 'creates the web site' {
        Assert-MockCalled New-RecreatedWebSite -ParameterFilter {
          $Name -eq $Config.name -and
          $Pool -eq $Config.app_pool.name -and
          $PhysicalPath -eq $Config.physical_path -and
          $Properties -eq $Config.properties
        }
      }

      It 'creates bindings' {
        Assert-MockCalled Install-WebBindings -ParameterFilter {
          $Site -eq $Config.name -and
          $Bindings[0] -eq $Config.bindings[0] -and
          $Bindings[1] -eq $Config.bindings[1]
        }
      }

      It 'starts the web site' {
        Assert-MockCalled Start-Website -ParameterFilter {
          $Name -eq $Config.name
        }
      }

      It 'tests HTTP responses' {
        Assert-MockCalled Test-HttpResponse -ParameterFilter {
          $Tests[0] -eq $Config.tests[0] -and
          $Tests[1] -eq $Config.tests[1]
        }
      }
    }

    Context 'uninstall' {
      Mock Out-Host
      Mock Stop-Website

      $Config = @{
        name = 'web site'
      }

      Install-Web -Config $Config -Uninstall

      It 'stops web site' {
        Assert-MockCalled Stop-Website -ParameterFilter {
          $Name -eq $Config.name
        }
      }

      It 'does not install web site' {
        Assert-MockCalled New-RecreatedWebAppPool -Exactly 0
      }
    }

    Context 'web site does not exist on uninstall' {
      Mock Out-Host
      Mock Stop-Website { throw 'does not exist' }

      $Config = @{
        name = 'web site'
      }

      It 'fails' {
        { Install-Web -Config $Config -Uninstall } | Should Throw
      }
    }
  }
}
