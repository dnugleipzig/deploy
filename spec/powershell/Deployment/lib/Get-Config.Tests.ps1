$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'Get-Config' {
  InModuleScope Deployment {
    Mock Out-Host

    Context 'hash' {
      $DeployYaml = 'TestDrive:\deploy.yaml'

      Set-Content -Path $DeployYaml -Value @"
foo: 42
is-null: ~
is-also-null: null
"@

      $Config = Get-Config -File $DeployYaml

      It 'converts to hashtable' {
        $Config.GetType().Name | Should Be 'Hashtable'
      }

      It 'converts data' {
        $Config.foo | Should Be 42
      }

      It 'supports null with ~' {
        $Config.'is-null' | Should Be $null
      }

      It 'supports null with null' {
        $Config.'is-also-null' | Should Be $null
      }
    }

    Context 'hash/hash' {
      $DeployYaml = 'TestDrive:\deploy.yaml'

      Set-Content -Path $DeployYaml -Value @"
hash:
  hash: 42
"@

      $Config = Get-Config -File $DeployYaml

      It 'converts to hashtable' {
        $Config.hash.GetType().Name | Should Be 'Hashtable'
        $Config.hash.hash.GetType().Name | Should Be 'Int32'
      }

      It 'converts data' {
        $Config.hash.hash | Should Be 42
      }
    }

    Context 'array/hash' {
      $DeployYaml = 'TestDrive:\deploy.yaml'

      Set-Content -Path $DeployYaml -Value @"
array:
  -
    hash: 42
"@

      $Config = Get-Config -File $DeployYaml

      It 'converts to array' {
        $Config.array.GetType().Name | Should Be 'Object[]'
        $Config.array[0].GetType().Name | Should Be 'Hashtable'
        $Config.array[0].hash.GetType().Name | Should Be 'Int32'
      }

      It 'converts data' {
        $Config.array[0].hash | Should Be 42
      }
    }

    Context 'hash/array' {
      $DeployYaml = 'TestDrive:\deploy.yaml'

      Set-Content -Path $DeployYaml -Value @"
hash:
  hash:
    - 42
"@

      $Config = Get-Config -File $DeployYaml

      It 'converts to hash' {
        $Config.hash.GetType().Name | Should Be 'Hashtable'
        $Config.hash.hash.GetType().Name | Should Be 'Object[]'
        $Config.hash.hash[0].GetType().Name | Should Be 'Int32'
      }

      It 'converts data' {
        $Config.hash.hash[0] | Should Be 42
      }
    }

    Context 'file does not exist' {
      It 'fails' {
        { Get-Config -File TestDrive:\does-not-exist.yaml } | Should Throw 'does-not-exist'
      }
    }

    Context 'invalid YAML' {
      $DeployYaml = 'TestDrive:\deploy.yaml'

      Set-Content -Path $DeployYaml -Value @"
Nothing: *forward
MyString: ForwardReference
"@

      It 'fails' {
        { Get-Config -File $DeployYaml } | Should Throw 'Exception calling "Load"'
      }
    }
  }
}
