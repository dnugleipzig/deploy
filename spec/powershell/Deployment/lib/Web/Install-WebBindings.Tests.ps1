$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'Install-WebBindings' {
  InModuleScope Deployment {
    Mock Out-Host
    Mock Get-WebBinding -ParameterFilter { $Name -eq $Site } { 'existing binding' }
    Mock Get-WebBinding -ParameterFilter { $Name -eq $Site -and $Protocol -eq 'https' } { @() }
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

    Context 'HTTP binding' {
      $Bindings = @(
        @{
          protocol = 'http'
          host_header = 'example.com'
        }
      )

      Install-WebBindings -Site $Site -Bindings $Bindings

      It 'adds binding' {
        Assert-MockCalled New-WebBinding -ParameterFilter {
          $Name -eq $Site -and
          $Protocol -eq $Bindings[0].protocol -and
          $HostHeader -eq $Bindings[0].host_header -and
          $Port -eq $null -and
          $IpAddress -eq $null
        }
      }
    }

    Context 'multiple bindings' {
      $Bindings = @(
        @{
          protocol = 'http'
          host_header = 'example.com'
        },
        @{
          protocol = 'http'
          host_header = 'www.example.com'
        }
      )

      Install-WebBindings -Site $Site -Bindings $Bindings

      It 'removes bindings from site' {
        Assert-MockCalled Remove-WebBinding -Exactly 1
      }

      It 'adds all bindings' {
        Assert-MockCalled New-WebBinding -ParameterFilter {
          $Name -eq $Site -and
          $Protocol -eq $Bindings[0].protocol -and
          $HostHeader -eq $Bindings[0].host_header
        }

        Assert-MockCalled New-WebBinding -ParameterFilter {
          $Name -eq $Site -and
          $Protocol -eq $Bindings[1].protocol -and
          $HostHeader -eq $Bindings[1].host_header
        }
      }
    }

    Context 'HTTPS binding with matching certificate' {
      $Bindings = @(
        @{
          protocol = 'https'
          host_header = 'example.com'
          port = 123
          ip_address = '1.2.3.4'
        }
      )

      Mock Get-WebBinding -ParameterFilter { $Name -eq $Site -and $Protocol -eq 'https' } {
        $GetAttributeValue = { '1.2.3.4:443:example.com' }
        $AddSslCertificate = { param($Hash) $Hash }

        $Binding = New-Object -TypeName PSObject

        Add-Member -InputObject $Binding -MemberType ScriptMethod -Name GetAttributeValue -Value $GetAttributeValue
        Add-Member -InputObject $Binding -MemberType ScriptMethod -Name AddSslCertificate -Value $AddSslCertificate

        @($Binding)
      }

      Mock Get-ChildItem -ParameterFilter { $Path -eq 'Cert:\LocalMachine\My' } {
        $Certificates = @(
          @{
            Extensions = @(
              @{
                Oid = @{
                  FriendlyName = 'subject alternative name'
                }
              },
              @{
                Oid = @{
                  FriendlyName = 'something'
                }
              }
            )
          },
          @{
            Extensions = @(
              @{
                Oid = @{
                  FriendlyName = 'subject alternative name'
                }
              }
            )
          }
        )

        $FormatNoMatch = { 'DNS Name=something.com' }
        $FormatMatch = { 'DNS Name=example.com' }
        $GetCertHashString = { 'certificate hash string' }

        Add-Member -InputObject $Certificates[0].Extensions[0] -MemberType ScriptMethod -Name Format -Value $FormatNoMatch

        Add-Member -InputObject $Certificates[1].Extensions[0] -MemberType ScriptMethod -Name Format -Value $FormatMatch
        Add-Member -InputObject $Certificates[1] -MemberType ScriptMethod -Name GetCertHashString -Value $GetCertHashString

        $Certificates
      }

      $Hash = Install-WebBindings -Site $Site -Bindings $Bindings

      It 'adds binding' {
        Assert-MockCalled New-WebBinding -ParameterFilter {
          $Name -eq $Site -and
          $Protocol -eq $Bindings[0].protocol -and
          $HostHeader -eq $Bindings[0].host_header -and
          $Port -eq $Bindings[0].port -and
          $IpAddress -eq $Bindings[0].ip_address
        }
      }

      It 'assigns certificate' {
        $Hash | Should Be 'certificate hash string'
      }
    }

    Context 'HTTPS binding without matching certificate' {
      $Bindings = @(
        @{
          protocol = 'https'
          host_header = 'example.com'
          port = 123
          ip_address = '1.2.3.4'
        }
      )

      Mock Get-WebBinding -ParameterFilter { $Name -eq $Site -and $Protocol -eq 'https' } {
        $GetAttributeValue = { '127.0.0.1:443:example.com' }
        $AddSslCertificate = { throw 'Should not be called' }

        $Binding = New-Object -TypeName PSObject

        Add-Member -InputObject $Binding -MemberType ScriptMethod -Name GetAttributeValue -Value $GetAttributeValue
        Add-Member -InputObject $Binding -MemberType ScriptMethod -Name AddSslCertificate -Value $AddSslCertificate

        @($Binding)
      }

      It 'fails' {
        { Install-WebBindings -Site $Site -Bindings $Bindings } | `
          Should Throw 'No certificate found for host header example.com'
      }

      It 'adds binding' {
        Assert-MockCalled New-WebBinding -ParameterFilter {
          $Name -eq $Site -and
          $Protocol -eq $Bindings[0].protocol -and
          $HostHeader -eq $Bindings[0].host_header -and
          $Port -eq $Bindings[0].port -and
          $IpAddress -eq $Bindings[0].ip_address
        }
      }
    }
  }
}
