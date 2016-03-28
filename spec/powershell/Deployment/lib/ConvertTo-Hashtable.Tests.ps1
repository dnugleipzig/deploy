$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'ConvertTo-Hashtable' {
  InModuleScope Deployment {
    Context '$null' {
      It 'yields $null' {
        ConvertTo-Hashtable $null | Should Be $null
      }
    }

    Context 'integer' {
      It 'yields value' {
        $Value = ConvertTo-Hashtable 42

        $Value | Should Be 42
        $Value.GetType().Name | Should Be 'Int32'
      }

      It 'converts strings that are parsable as integers' {
        $Value = ConvertTo-Hashtable '42'

        $Value | Should Be 42
        $Value.GetType().Name | Should Be 'Int32'
      }
    }

    Context 'boolean' {
      It 'yields value' {
        $Value = ConvertTo-Hashtable $true

        $Value | Should Be $true
        $Value.GetType().Name | Should Be 'Boolean'
      }

      It 'converts strings that are parsable as boolean' {
        $Value = ConvertTo-Hashtable 'true'

        $Value | Should Be $true
        $Value.GetType().Name | Should Be 'Boolean'
      }
    }

    Context 'string' {
      It 'yields value' {
        ConvertTo-Hashtable 'string' | Should Be 'string'
      }
    }

    Context 'hash' {
      It 'yields value' {
        $Result = ConvertTo-Hashtable @{ foo = 42 }

        $Result.foo | Should Be 42
      }
    }

    Context 'array' {
      It 'yields values' {
        $Result = ConvertTo-Hashtable @(1, 2)

        $Result | Should Be @(1, 2)
      }
    }

    Context 'array/hash' {
      It 'yields values' {
        $Result = ConvertTo-Hashtable @(@{ foo = 1}, @{ force_array = 1})

        $Result[0].foo | Should Be 1
      }
    }

    Context 'hash/array/hash' {
      It 'yields values' {
        $Result = ConvertTo-Hashtable @{ foo = @(@{ bar = 1}, @{ force_array = 1}) }

        $Result.foo[0].bar | Should Be 1
      }
    }

    Context 'hash/array' {
      It 'yields values' {
        $Result = ConvertTo-Hashtable @{ foo = @(1, 2) }

        $Result.foo | Should Be @(1, 2)
      }
    }

    Context 'PowerShell object' {
      It 'converts properties to hash keys' {
        $Object = [PSCustomObject] @{ foo = 42; bar = '23' }
        $Object | Add-Member -MemberType NoteProperty -Name baz -Value 123

        $Result = ConvertTo-Hashtable $Object

        $Result.foo | Should Be 42
        $Result.bar | Should Be '23'
        $Result.baz | Should Be 123
      }

      It 'supports nested values' {
        $Object = [PSCustomObject] @{ nested = @{ value = 'nested value' } }

        $Result = ConvertTo-Hashtable $Object

        $Result.nested.value | Should Be 'nested value'
      }

      It 'supports nested psobjects' {
        $Object = [PSCustomObject] @{ nested = [PSCustomObject] @{ value = 'nested value' } }

        $Result = ConvertTo-Hashtable $Object

        $Result.nested.value | Should Be 'nested value'
      }
    }
  }
}
