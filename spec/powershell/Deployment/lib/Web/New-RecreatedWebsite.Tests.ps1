$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'New-RecreatedWebsite' {
  InModuleScope Deployment {
    $Params = @{
      Name = 'web site'
      Pool = 'application pool'
      PhysicalPath = 'physical path'
    }

    $Site = @{
      Name = 'newly created site'
    }

    Mock Out-Host
    Mock Test-Path
    Mock Remove-Website
    Mock Resolve-Path { $Path } -ParameterFilter { $Path -eq $Params.PhysicalPath }
    Mock New-Website { $Site }
    Mock Set-WebConfigurationProperty

    Context 'site exists' {
      Mock Test-Path { $true }

      New-RecreatedWebsite @Params

      It 'removes site' {
        Assert-MockCalled Remove-Website -ParameterFilter { $Name -eq $Params.Name }
      }
    }

    Context 'site does not exist' {
      Mock Test-Path { $false }

      New-RecreatedWebsite @Params

      It 'does not remove site' {
        Assert-MockCalled Remove-Website -Exactly 0
      }
    }

    Context 'site' {
      $Created = New-RecreatedWebsite @Params

      It 'creates new web site' {
        Assert-MockCalled New-Website -ParameterFilter {
          $Name -eq $Params.Name -and
          $ApplicationPool -eq $Params.Pool -and
          $PhysicalPath -eq $Params.PhysicalPath
        }
      }

      It 'sets default logging properties' {
        Assert-MockCalled Set-WebConfigurationProperty -ParameterFilter {
          $Name -eq 'LogFile.LogExtFileFlags'
        }
      }

      It 'configures frequent hit parameters to put files into the compression cache' {
        Assert-MockCalled Set-WebConfigurationProperty -ParameterFilter {
          $Name -eq 'frequentHitThreshold'
        }

        Assert-MockCalled Set-WebConfigurationProperty -ParameterFilter {
          $Name -eq 'frequentHitTimePeriod'
        }
      }

      It 'does not set properties beyond defaults' {
        Assert-MockCalled Set-WebConfigurationProperty -Exactly 3
      }

      It 'returns site' {
        $Created | Should Be $Site
      }
    }

    Context 'properties' {
      $Params.Add('Properties', @{
        id = 42
        log_file = @{
          directory = 'absolute-path://../../logs'
          log_ext_file_flags = 'Date,Time'
        }
      })

      New-RecreatedWebsite @Params

      It 'sets web site ID' {
        Assert-MockCalled Set-WebConfigurationProperty -ParameterFilter {
          $WarningAction|Out-Host
          $Filter -eq "/system.applicationHost/sites/site[@name='$($Site.Name)']" -and
          $PSPath -eq 'IIS:\' -and
          $Name -eq 'Id' -and
          $Value -eq 42
        }
      }

      It 'sets log file directory property' {
        Assert-MockCalled Set-WebConfigurationProperty -ParameterFilter {
          $Filter -eq "/system.applicationHost/sites/site[@name='$($Site.Name)']" -and
          $PSPath -eq 'IIS:\' -and
          $Name -eq 'LogFile.Directory' -and
          $Value -eq [System.IO.Path]::GetFullPath('../../logs')
        }
      }

      It 'sets log ext flags property' {
        Assert-MockCalled Set-WebConfigurationProperty -ParameterFilter {
          $Filter -eq "/system.applicationHost/sites/site[@name='$($Site.Name)']" -and
          $PSPath -eq 'IIS:\' -and
          $Name -eq 'LogFile.LogExtFileFlags' -and
          $Value -match 'Date,Time'
        }
      }
    }
  }
}
