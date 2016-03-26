$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'Find-NuGet' {
  InModuleScope Deployment {
    Mock Out-Host

    Context 'nuget.exe exists' {
      It 'returns path' {
        New-Item -Type File -Path TestDrive:\nuget.exe

        $Path = Find-NuGet -Path TestDrive:\nuget.exe

        $Path | Should Be TestDrive:\nuget.exe
      }
    }

    Context 'nuget.exe does not exist' {
      Mock Invoke-WebRequest

      $Path = 'TestDrive:\some\directory\nuget.exe'

      $Result = Find-NuGet -Path $Path

      It 'creates target directory' {
        'TestDrive:\some\directory' | Should Exist
      }

      It 'downloads nuget.exe' {
        Assert-MockCalled Invoke-WebRequest -ParameterFilter { $Uri -eq 'https://www.nuget.org/nuget.exe' -and $OutFile -eq $Path }
      }

      It 'returns path' {
        $Result | Should Be $Path
      }
    }

    Context 'nuget.exe download fails' {
      Mock Invoke-WebRequest { throw 'Download failed' }

      It 'fails' {
        { Find-NuGet -Path 'TestDrive:\some\directory\nuget.exe' } | Should Throw 'Could not download NuGet'
      }
    }
  }
}
