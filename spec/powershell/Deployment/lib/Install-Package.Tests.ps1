$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'Install-Package' {
  InModuleScope Deployment {
    Mock Out-Host
    Mock Find-NuGet
    Mock Exec
    Mock Import-Module

    Context 'package without version' {
      $Package = @{
        Id = 'Some.Package'
      }

      Install-Package @Package -OutputDirectory 'TestDrive:\nugets'

      It 'finds NuGet' {
        Assert-MockCalled Find-NuGet -Exactly 1
      }

      It 'installs latest package version' {
        Assert-MockCalled Exec
      }

      It 'does not import the package dll' {
        Assert-MockCalled Import-Module -Exactly 0
      }
    }

    Context 'package with version' {
     $Package = @{
        Id = 'Some.Package'
        Version = '1.2.3'
      }

      Install-Package @Package -OutputDirectory 'TestDrive:\nugets'

      It 'finds NuGet' {
        Assert-MockCalled Find-NuGet -Exactly 1
      }

      It 'installs package with version' {
        Assert-MockCalled Exec
      }

      It 'does not import the package dll' {
        Assert-MockCalled Import-Module -Exactly 0
      }
    }

    Context 'package with import' {
      $Package = @{
        Id = 'Some.Package'
        Version = '1.2.3'
        Import = 'lib/package.dll'
      }

      Install-Package @Package -OutputDirectory 'TestDrive:\nugets'

      It 'finds NuGet' {
        Assert-MockCalled Find-NuGet -Exactly 1
      }

      It 'installs package' {
        Assert-MockCalled Exec
      }

      It 'imports the package dll' {
        Assert-MockCalled Import-Module -ParameterFilter { $Name -eq 'TestDrive:\nugets\Some.Package\lib\package.dll' }
      }
    }

    Context 'package with import' {
      $Package = @{
        Id = 'Some.Package'
        Version = '1.2.3'
        Import = @('lib/1.dll', 'lib/2.dll')
      }

      Install-Package @Package -OutputDirectory 'TestDrive:\nugets'

      It 'finds NuGet' {
        Assert-MockCalled Find-NuGet -Exactly 1
      }

      It 'installs package' {
        Assert-MockCalled Exec
      }

      It 'imports the first package dll' {
        Assert-MockCalled Import-Module -ParameterFilter { $Name -eq 'TestDrive:\nugets\Some.Package\lib\1.dll' }
      }

      It 'imports the first package dll' {
        Assert-MockCalled Import-Module -ParameterFilter { $Name -eq 'TestDrive:\nugets\Some.Package\lib\2.dll' }
      }
    }
  }
}
