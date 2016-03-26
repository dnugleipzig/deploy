$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'Expand-Hashtable' {
  InModuleScope Deployment {
    Context '$null' {
      $Hash = $null

      It 'yields $null' {
        $Hash | Expand-Hashtable | Should Be $null
      }
    }

    Context 'empty hash' {
      $Hash = @{}

      It 'yields $null' {
        $Hash | Expand-Hashtable | Should Be $null
      }
    }

    Context 'hash' {
      $Hash = [ordered]@{
        foo = 42
        bar = 23
        baz = $null
      }

      It 'yields paths and values' {
        $Flattened = $Hash | Expand-Hashtable

        $Flattened[0].Path | Should Be @('foo')
        $Flattened[0].Value | Should Be 42
        $Flattened[1].Path | Should Be @('bar')
        $Flattened[1].Value | Should Be 23
        $Flattened[2].Path | Should Be @('baz')
        $Flattened[2].Value | Should Be $null
      }
    }

    Context 'nested hash' {
      $Hash = [ordered]@{
        foo = [ordered]@{
          bar = 42
          baz = 23
        }
        foobar = [ordered]@{
          baz = [ordered]@{
            blah = 123
          }
        }
        shizzle = [ordered]@{
          foo = $null
        }
      }

      It 'yields paths and values' {
        $Flattened = $Hash | Expand-Hashtable

        $Flattened[0].Path | Should Be @('foo', 'bar')
        $Flattened[0].Value | Should Be 42
        $Flattened[1].Path | Should Be @('foo', 'baz')
        $Flattened[1].Value | Should Be 23
        $Flattened[2].Path | Should Be @('foobar', 'baz', 'blah')
        $Flattened[2].Value | Should Be 123
        $Flattened[3].Path | Should Be @('shizzle', 'foo')
        $Flattened[3].Value | Should Be $null
      }
    }

    Context 'mixed hash' {
      $Hash = [ordered]@{
        foo = 42
        bar = [ordered]@{
          baz = [ordered]@{
            blah = 123
          }
        }
      }

      It 'yields paths and values' {
        $Flattened = $Hash | Expand-Hashtable

        $Flattened[0].Path | Should Be @('foo')
        $Flattened[0].Value | Should Be 42
        $Flattened[1].Path | Should Be @('bar', 'baz', 'blah')
        $Flattened[1].Value | Should Be 123
      }
    }
  }
}
