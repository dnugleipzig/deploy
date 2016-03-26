$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'New-RecreatedWebAppPool' {
  InModuleScope Deployment {
    $Params = @{
      Name = 'application pool'
    }

    $Pool = @{
      Name = 'newly created pool'
    }

    Mock Out-Host
    Mock Test-Path
    Mock Remove-WebAppPool
    Mock New-WebAppPool { $Pool }
    Mock Set-WebConfigurationProperty

    Context 'pool exists' {
      Mock Test-Path { $true }

      New-RecreatedWebAppPool @Params

      It 'removes pool' {
        Assert-MockCalled Remove-WebAppPool -ParameterFilter { $Name -eq $Params.Name }
      }
    }

    Context 'pool does not exist' {
      Mock Test-Path { $false }

      New-RecreatedWebAppPool @Params

      It 'does not remove pool' {
        Assert-MockCalled Remove-WebAppPool -Exactly 0
      }
    }

    Context 'pool' {
      $Created = New-RecreatedWebAppPool @Params

      It 'creates new pool' {
        Assert-MockCalled New-WebAppPool -ParameterFilter { $Name -eq $Params.Name }
      }

      It 'does not set properties' {
        Assert-MockCalled Set-WebConfigurationProperty -Exactly 0
      }

      It 'returns pool' {
        $Created | Should Be $Pool
      }
    }

    Context 'properties' {
      $Params.Add('Properties', @{
        process_model = @{
          identity_type = 'NetworkService'
        }
        managed_runtime_version = 'v4.0'
      })

      New-RecreatedWebAppPool @Params

      It 'sets process identity' {
        Assert-MockCalled Set-WebConfigurationProperty -ParameterFilter {
          $Filter -eq "/system.applicationHost/applicationPools/add[@name='$($Pool.Name)']" -and
          $PSPath -eq 'IIS:\' -and
          $Name -eq 'ProcessModel.IdentityType' -and
          $Value -eq 'NetworkService'
        }
      }

      It 'sets log file directory property' {
        Assert-MockCalled Set-WebConfigurationProperty -ParameterFilter {
          $Filter -eq "/system.applicationHost/applicationPools/add[@name='$($Pool.Name)']" -and
          $PSPath -eq 'IIS:\' -and
          $Name -eq 'ManagedRuntimeVersion' -and
          $Value -eq 'v4.0'
        }
      }
    }
  }
}
