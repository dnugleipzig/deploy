$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'ConvertTo-PascalCase' {
  InModuleScope Deployment {
    Context 'contains no underscores'{
      $Value = 'AlreadyPascalCase'

      It 'yields string' {
        ConvertTo-PascalCase -Value $Value | Should Be $Value
      }
    }

    Context 'lowercase' {
      $Value = 'value'

      It 'yields upcased string' {
        ConvertTo-PascalCase -Value $Value | Should Be "Value"
      }
    }

    Context 'snake case' {
      $Value = 'the_value'

      It 'yields pascalized string' {
        ConvertTo-PascalCase -Value $Value | Should Be "TheValue"
      }
    }

    Context 'snake case with double underscores' {
      $Value = 'the__value'

      It 'yields pascalized string' {
        ConvertTo-PascalCase -Value $Value | Should Be "TheValue"
      }
    }

    Context 'piping'{
      $Value = 'the_value'

      It 'is supported' {
        $Pascalized = @($Value, $Value) | ConvertTo-PascalCase

        $Pascalized[0] | Should Be "TheValue"
        $Pascalized[1] | Should Be "TheValue"
      }
    }
  }
}
