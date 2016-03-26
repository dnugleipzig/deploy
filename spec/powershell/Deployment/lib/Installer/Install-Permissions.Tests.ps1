$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'Install-Permissions' {
  InModuleScope Deployment {
    Mock Out-Host
    Mock Set-Permission
    Mock Set-Acl

    Context 'no permissions' {
      Install-Permissions -Config @{}

      It 'does not set permissions' {
        Assert-MockCalled Set-Permission -Exactly 0
      }
    }

    Context 'permissions to set' {
      $Config = @{
        dir1 = @{
          FullControl = @('sid://BuiltinAdministratorsSid')
        }
        'dir2/dir3' = @{
          FullControl = @('sid://BuiltinAdministratorsSid')
          Modify = @('sid://LocalSystemSid')
        }
        'no-perms' = $null
      }

      $Cwd = 'TestDrive:\current'

      try
      {
        $OldPwd = Get-Location
        New-Item -Type Directory -Path $Cwd
        Set-Location -Path $Cwd

        Install-Permissions -Config $Config
      }
      finally
      {
        Set-Location $OldPwd
      }

      It 'sets permission for directory with single permission' {
        Assert-MockCalled Set-Permission -ParameterFilter { $Path -eq 'dir1' -and $Permissions -eq $Config.dir1 }
      }

      It 'sets permission for directory with multiple permission' {
        Assert-MockCalled Set-Permission -ParameterFilter { $Path -eq 'dir2/dir3' -and $Permissions -eq $Config.'dir2/dir3' }
      }

      It 'sets permission for directory without permissions' {
        Assert-MockCalled Set-Permission -ParameterFilter { $Path -eq 'no-perms' -and $Permissions -eq $null }
      }

      It 'does not set permissions for current directory' {
        Assert-MockCalled Set-Acl -Exactly 0
      }
    }

    Context 'permissions to set in current directory' {
      $Config = @{
        '.' = @{
          FullControl = @('sid://BuiltinAdministratorsSid')
        }
      }

      $Cwd = 'TestDrive:\current'

      try
      {
        $OldPwd = Get-Location
        New-Item -Type Directory -Path $Cwd
        Set-Location -Path $Cwd

        Install-Permissions -Config $Config
      }
      finally
      {
        Set-Location $OldPwd
      }

      It 'removes inherited permissions for current directory' {
        Assert-MockCalled Set-Acl -ParameterFilter {
          $PropagatedPermissions = ($AclObject.Access |
            Where-Object { $_.PropagationFlags -ne 'None' } |
            Measure-Object).Count

          $Path -eq $Cwd -and $PropagatedPermissions -eq 0
        }
      }
    }

    Context 'permissions to set in current directory with absolute path' {
      $Config = @{
        'TestDrive:\current' = @{
          FullControl = @('sid://BuiltinAdministratorsSid')
        }
      }

      $Cwd = 'TestDrive:\current'

      try
      {
        $OldPwd = Get-Location
        New-Item -Type Directory -Path $Cwd
        Set-Location -Path $Cwd

        Install-Permissions -Config $Config
      }
      finally
      {
        Set-Location $OldPwd
      }

      It 'removes inherited permissions for current directory' {
        Assert-MockCalled Set-Acl -ParameterFilter {
          $PropagatedPermissions = ($AclObject.Access |
            Where-Object { $_.PropagationFlags -ne 'None' } |
            Measure-Object).Count

          $Path -eq $Cwd -and $PropagatedPermissions -eq 0
        }
      }
    }

    Context 'uninstall' {
      $Config = @{
        dir1 = @{
          FullControl = @('sid://BuiltinAdministratorsSid')
        }
        'dir2/dir3' = @{
          Modify = @('sid://LocalSystemSid')
        }
      }

      Install-Permissions -Config $Config -Uninstall

      It 'does not set permissions' {
        Assert-MockCalled Set-Permission -Exactly 0
      }
    }
  }
}
