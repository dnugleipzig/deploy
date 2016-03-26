$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'Set-Permission' {
  InModuleScope Deployment {
    Mock Out-Host
    Mock Set-Acl

    Context 'path does not exist' {
      It 'creates directory' {
        Set-Permission -Path 'TestDrive:\foo' -Permissions @{}

        'TestDrive:\foo' | Should Exist
      }

      It 'creates nested directory' {
        Set-Permission -Path 'TestDrive:\bar\baz' -Permissions @{}

        'TestDrive:\bar\baz' | Should Exist
      }

      It 'creates nested directory for unnormalized path' {
        Set-Permission -Path 'TestDrive:\bar\..\foobar/baz' -Permissions @{}

        'TestDrive:\foobar\baz' | Should Exist
      }
    }

    Context 'no permissions' {
      Set-Permission -Path 'TestDrive:\frotz' -Permissions $null

      It 'creates directory' {
        'TestDrive:\frotz' | Should Exist
      }

      It 'does not set ACL' {
        Assert-MockCalled Set-Acl -Exactly 0
      }
    }

    Context 'permissions' {
      $Permissions = @{
        FullControl = @('sid://BuiltinAdministratorsSid')
        Modify = @('sid://LocalSystemSid')
      }

      Set-Permission -Path 'TestDrive:\dir1/dir2' -Permissions $Permissions

      It 'creates nested directory' {
        'TestDrive:\dir1\dir2' | Should Exist
      }

      It 'sets ACL' {
        Assert-MockCalled Set-Acl -ParameterFilter { $Path -eq 'TestDrive:\dir1\dir2' }
      }

      It 'creates ACE for first permission' {
        Assert-MockCalled Set-Acl -ParameterFilter {
          $Access = $AclObject.Access | Where-Object {
            $_.IdentityReference -match 'BUILTIN\\' -and
            $_.FileSystemRights -eq 'FullControl' -and
            $_.InheritanceFlags -eq 'ContainerInherit, ObjectInherit' -and
            $_.PropagationFlags -eq 'None' -and
            $_.AccessControlType -eq 'Allow'
          }

          ($Access | Measure-Object).Count -eq 1
        }
      }

     It 'creates ACE for second permission' {
        Assert-MockCalled Set-Acl -ParameterFilter {
          $Access = $AclObject.Access | Where-Object {
            $_.IdentityReference -match 'SYSTEM' -and
            $_.FileSystemRights -match 'Modify' -and
            $_.InheritanceFlags -eq 'ContainerInherit, ObjectInherit' -and
            $_.PropagationFlags -eq 'None' -and
            $_.AccessControlType -eq 'Allow'
          }

          ($Access | Measure-Object).Count -eq 1
        }
      }

      It 'does not have inherited ACEs' {
        Assert-MockCalled Set-Acl -ParameterFilter {
          $PropagatedPermissions = ($AclObject.Access |
            Where-Object { $_.PropagationFlags -ne 'None' } |
            Measure-Object).Count

          $PropagatedPermissions -eq 0
        }
      }
    }

    Context 'permissions relative to current directory' {
      $Permissions = @{
        FullControl = @('sid://BuiltinAdministratorsSid')
        Modify = @('sid://LocalSystemSid')
      }

      $Cwd = 'TestDrive:\current'

      try
      {
        $OldPwd = Get-Location
        New-Item -Type Directory -Path $Cwd
        Set-Location -Path $Cwd

        Set-Permission -Path 'dir1/dir2' -Permissions $Permissions
      }
      finally
      {
        Set-Location $OldPwd
      }

      It 'creates nested directory' {
        'TestDrive:\current\dir1\dir2' | Should Exist
      }

      It 'sets ACL' {
        Assert-MockCalled Set-Acl -ParameterFilter { $Path -eq 'TestDrive:\current\dir1\dir2' }
      }
    }
  }
}
