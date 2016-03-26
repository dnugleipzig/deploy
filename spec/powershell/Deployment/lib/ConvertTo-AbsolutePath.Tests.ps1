$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'ConvertTo-AbsolutePath' {
  InModuleScope Deployment {
    Context 'path to absolutize' {
      It 'returns path' {
        $Path = ConvertTo-AbsolutePath -Path 'absolute-path://path'

        $Path | Should Be ([System.IO.Path]::GetFullPath('path'))
      }

      It 'supports piping' {
        $Path = 'absolute-path://path' | ConvertTo-AbsolutePath

        $Path | Should Be ([System.IO.Path]::GetFullPath('path'))
      }
    }

    Context 'not a path to absolutize' {
      It 'returns value as-is' {
        $Value = ConvertTo-AbsolutePath -Path 'not a path'

        $Value | Should Be 'not a path'
      }

      It 'supports piping' {
        $Value = 'not a path' | ConvertTo-AbsolutePath

        $Value | Should Be 'not a path'
      }
    }

    Context 'data type' {
      It 'returns value as-is' {
        $Value = ConvertTo-AbsolutePath -Path 42

        $Value.GetType().Name | Should Be 'Int32'
      }
    }

    Context 'mixed piping' {
      It 'succeeds' {
        $Values = @('absolute-path://path', 'not a path') | ConvertTo-AbsolutePath

        $Values[0] | Should Be ([System.IO.Path]::GetFullPath('path'))
        $Values[1] | Should Be 'not a path'
      }
    }
  }
}
