$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'Install-WebBindings' {
  InModuleScope Deployment {
    Mock Out-Host
    Mock Get-WebBinding { 'existing binding' }
    Mock Remove-WebBinding
    Mock New-WebBinding

    $Site = 'web site'

    Context 'null bindings' {
      $Bindings = $null

      Install-WebBindings -Site $Site -Bindings $Bindings

      It 'removes bindings from site' {
        Assert-MockCalled Remove-WebBinding -Exactly 1
      }

      It 'adds no binding' {
        Assert-MockCalled New-WebBinding -Exactly 0
      }
    }

    Context 'no bindings' {
      $Bindings = @()

      Install-WebBindings -Site $Site -Bindings $Bindings

      It 'removes bindings from site' {
        Assert-MockCalled Remove-WebBinding -Exactly 1
      }

      It 'adds no binding' {
        Assert-MockCalled New-WebBinding -Exactly 0
      }
    }

    Context 'bindings' {
      $Bindings = @(
        @{
          protocol = 'http'
          host_header = 'example.com'
        },
        @{
          protocol = 'https'
          host_header = 'example.com'
          port = 123
          ip_address = '1.2.3.4'
        }
      )

      Install-WebBindings -Site $Site -Bindings $Bindings

      It 'removes bindings from site' {
        Assert-MockCalled Remove-WebBinding -Exactly 1
      }

      It 'adds HTTP binding' {
        Assert-MockCalled New-WebBinding -ParameterFilter {
          $Name -eq $Site -and
          $Protocol -eq $Bindings[0].protocol -and
          $HostHeader -eq $Bindings[0].host_header
          $Port -eq $null
          $IpAddress -eq $null
        }
      }

      It 'adds HTTPS binding' {
        Assert-MockCalled New-WebBinding -ParameterFilter {
          $Name -eq $Site -and
          $Protocol -eq $Bindings[1].protocol -and
          $HostHeader -eq $Bindings[1].host_header
          $Port -eq $Bindings[1].port
          $IpAddress -eq $Bindings[1].ip_address
        }
      }
    }
  }
}
