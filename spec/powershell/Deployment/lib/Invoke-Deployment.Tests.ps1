$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'Invoke-Deployment' {
  New-Module -Name Deployment -ScriptBlock {
    function Install-Foo { param($Config, $Uninstall) }
    function Install-Bar { param($Config, $Uninstall) }
    function Install-Success { param($Config, $Uninstall) }
    function Install-Failing { param($Config, $Uninstall) }
  }

  Mock -Module Deployment Out-Host
  Mock -Module Deployment Set-RootDirectory

  It 'should load config from file' {
    Mock -Module Deployment Get-Config {
      Return @{}
    }

    Invoke-Deployment -Root '.' -ConfigFile 'deploy.yaml'

    Assert-MockCalled -Module Deployment Get-Config -ParameterFilter { $File -eq 'deploy.yaml' }
  }

  It 'should set root directory' {
    Invoke-Deployment -Root '.' -ConfigFile 'deploy.yaml'

    Assert-MockCalled -Module Deployment Set-RootDirectory -ParameterFilter { $Path -eq '.' }
  }

  Context 'no deployment' {
    Mock -Module Deployment Get-Config {
      Return @{}
    }

    Invoke-Deployment -Root '.' -ConfigFile 'deploy.yaml'

    It 'succeeds' {
      $true | Should Be $true
    }
  }

  Context 'install none' {
    Mock -Module Deployment Get-Config {
      Return @{
        deployment = @{}
      }
    }

    Invoke-Deployment -Root '.' -ConfigFile 'deploy.yaml'

    It 'succeeds' {
      $true | Should Be $true
    }
  }

  Context 'install' {
    Mock -Module Deployment Install-Foo

    Mock -Module Deployment Get-Config {
      Return @{
        deployment = @{
          foo = @{
            parameter = 42
          }
        }
      }
    }

    Invoke-Deployment -Root '.' -ConfigFile 'deploy.yaml'

    It 'calls installer' {
      Assert-MockCalled -Module Deployment Install-Foo
    }

    It 'passes config' {
      Assert-MockCalled -Module Deployment Install-Foo -ParameterFilter { $Config.parameter -eq 42 }
    }
  }

  Context 'install null' {
    Mock -Module Deployment Install-Foo

    Mock -Module Deployment Get-Config {
      Return @{
        deployment = @{
          foo = $null
        }
      }
    }

    Invoke-Deployment -Root '.' -ConfigFile 'deploy.yaml'

    It 'calls installer' {
      Assert-MockCalled -Module Deployment Install-Foo
    }

    It 'passes config' {
      Assert-MockCalled -Module Deployment Install-Foo -ParameterFilter { $Config -eq $null }
    }
  }

  Context 'install multiple' {
    $global:Order = @()
    Mock -Module Deployment Install-Foo {
      $global:Order += $Config.index
    }

    Mock -Module Deployment Get-Config {
      Return @{
        deployment = @(
          @{
            foo = @{
              index = 1
            }
          },
          @{
            foo = @{
              index = 2
            }
          }
        )
      }
    }

    Invoke-Deployment -Root '.' -ConfigFile 'deploy.yaml'

    It 'calls installers' {
      Assert-MockCalled -Module Deployment Install-Foo -Exactly 2

      $global:Order[0] | Should Be 1
      $global:Order[1] | Should Be 2
    }

    It "passes the first installer's config" {
      Assert-MockCalled -Module Deployment Install-Foo -ParameterFilter { $Config.index -eq 1 }
    }

    It "passes the second installer's config" {
      Assert-MockCalled -Module Deployment Install-Foo -ParameterFilter { $Config.index -eq 2 }
    }
  }

  Context 'uninstall' {
    Mock -Module Deployment Install-Foo

    Mock -Module Deployment Get-Config {
      Return @{
        deployment = @{
          foo = @{
            parameter = 42
          }
        }
      }
    }

    Invoke-Deployment -Uninstall -Root '.' -ConfigFile 'deploy.yaml'

    It 'calls installer' {
      Assert-MockCalled -Module Deployment Install-Foo
    }

    It 'calls installer with uninstall switch' {
      Assert-MockCalled -Module Deployment Install-Foo -ParameterFilter { $Uninstall -eq $true }
    }

    It 'passes config' {
      Assert-MockCalled -Module Deployment Install-Foo -ParameterFilter { $Config.parameter -eq 42 }
    }
  }

  Context 'uninstall multiple' {
    $global:Order = @()
    Mock -Module Deployment Install-Foo {
      $global:Order += $Config.index
    }

    Mock -Module Deployment Get-Config {
      Return @{
        deployment = @(
          @{
            foo = @{
              index = 1
            }
          },
          @{
            foo = @{
              index = 2
            }
          }
        )
      }
    }


    Invoke-Deployment -Uninstall -Root '.' -ConfigFile 'deploy.yaml'

    It 'calls installers in reverse order' {
      Assert-MockCalled -Module Deployment Install-Foo -Exactly 2

      $global:Order[0] | Should Be 2
      $global:Order[1] | Should Be 1
    }

    It 'calls installers with uninstall switch' {
      Assert-MockCalled -Module Deployment Install-Foo -Exactly 2 -ParameterFilter { $Uninstall -eq $true }
    }

    It "passes the first installer's config" {
      Assert-MockCalled -Module Deployment Install-Foo -ParameterFilter { $Config.index -eq 1 }
    }

    It "passes the second installer's config" {
      Assert-MockCalled -Module Deployment Install-Foo -ParameterFilter { $Config.index -eq 2 }
    }
  }

  Context 'install fails' {
    Mock -Module Deployment Install-Failing {
      Get-Content -Path 'TestDrive:\does-not-exist' -ErrorAction Stop
    }

    Mock -Module Deployment Install-Success

    Mock -Module Deployment Get-Config {
      Return @{
        deployment = @{
          failing = @{}
          success = @{}
        }
      }
    }

    It 'fails deployment' {
      { Invoke-Deployment -Root '.' -ConfigFile 'deploy.yaml' } | Should Throw 'does-not-exist'
    }

    It 'calls the failing installer' {
      { Invoke-Deployment -Root '.' -ConfigFile 'deploy.yaml' } | Should Throw

      Assert-MockCalled -Module Deployment Install-Failing
    }

    It 'does not call installers after the failing installer' {
      { Invoke-Deployment -Root '.' -ConfigFile 'deploy.yaml' } | Should Throw

      Assert-MockCalled -Module Deployment Install-Success -Exactly 0
    }
  }

  Context 'uninstall fails' {
    Mock -Module Deployment Install-Failing {
      Get-Content -Path 'TestDrive:\does-not-exist' -ErrorAction Stop
    }

    Mock -Module Deployment Install-Success
    Mock -Module Deployment Write-Error

    Mock -Module Deployment Get-Config {
      Return @{
        deployment = @{
          success = @{}
          failing = @{}
        }
      }
    }

    It 'does not fail deployment' {
      { Invoke-Deployment -Uninstall -Root '.' -ConfigFile 'deploy.yaml' } | Should Not Throw
    }

    It 'calls the failing installer' {
      Invoke-Deployment -Uninstall -Root '.' -ConfigFile 'deploy.yaml'

      Assert-MockCalled -Module Deployment Install-Failing
    }

    It 'prints the error' {
      Invoke-Deployment -Uninstall -Root '.' -ConfigFile 'deploy.yaml'

      Assert-MockCalled -Module Deployment Write-Error
    }

    It 'calls remaining installers' {
      Invoke-Deployment -Uninstall -Root '.' -ConfigFile 'deploy.yaml'

      Assert-MockCalled -Module Deployment Install-Success
    }
  }
}

Describe 'Invoke-Deployment examples' {
  Mock -Module Deployment Out-Host
  Mock -Module Deployment Set-RootDirectory

  $DeployYaml = 'TestDrive:\deploy.yaml'

  Context 'web application' {
    Mock -Module Deployment Install-Requirements
    Mock -Module Deployment Install-Permissions
    Mock -Module Deployment Install-Certificates
    Mock -Module Deployment Install-Web

    Set-Content -Path $DeployYaml -Value @"
application:
  name: example.com
  dns:
    -
      type: a
      name: example.com
      value: 1.2.3.4
deployment:
  - requirements:
    - NETFramework451
    - UrlRewrite2
  - permissions:
      .:
        FullControl:
          - sid://BuiltinAdministratorsSid
          - sid://LocalSystemSid
      bin:
        ReadAndExecute:
          - IUSR
          - IIS_IUSRs
      logs:
        Modify:
          - IIS_IUSRs
  - certificates:
      example.com.pfx: env://CERT_PASSWORD
  - web:
      name: example.com
      physical_path: bin
      # Properties:
      #   Get-Item 'IIS:\Sites\Default Web Site\' | Get-Member -MemberType NoteProperty
      # Details:
      #   (Get-Item 'IIS:\Sites\Default Web Site\').id
      #   (Get-Item 'IIS:\Sites\Default Web Site\').logFile
      properties:
        id: 42
        log_file:
          directory: ../../logs2
          log_ext_file_flags: Date,Time
      app_pool:
        name: Example Application Pool
        # Properties:
        #   Get-Item IIS:\AppPools\DefaultAppPool\ | Get-Member -MemberType NoteProperty
        # Details:
        #   (Get-Item IIS:\AppPools\DefaultAppPool\).managedRuntimeVersion
        #   (Get-Item IIS:\AppPools\DefaultAppPool\).processModel
        properties:
          process_model:
            identity_type: NetworkService
          managed_runtime_version: v4.0
      bindings:
        -
          protocol: http
          host_header: example.com
        -
          protocol: https
          host_header: example.com
      tests:
        -
          method: GET
          url: http://example.com/
          expect:
            status: 200
            url: http://example.com/
"@

    Invoke-Deployment -Root '.' -ConfigFile $DeployYaml

    It 'installs requirements' {
      Assert-MockCalled -Module Deployment Install-Requirements -ParameterFilter { $Config[0] -eq 'NETFramework451' }
    }

    It 'installs permissions' {
      Assert-MockCalled -Module Deployment Install-Permissions -ParameterFilter { $Config.'.'.FullControl[0] -eq 'sid://BuiltinAdministratorsSid' }
    }

    It 'installs certificates' {
      Assert-MockCalled -Module Deployment Install-Certificates -ParameterFilter { $Config.'example.com.pfx' -eq 'env://CERT_PASSWORD' }
    }

    It 'installs web application' {
      Assert-MockCalled -Module Deployment Install-Web -ParameterFilter { $Config.name -eq 'example.com' }
    }
  }

  Context 'windows service' {
    Mock -Module Deployment Install-Requirements
    Mock -Module Deployment Install-Permissions
    Mock -Module Deployment Install-Packages
    Mock -Module Deployment Install-Custom

    Set-Content -Path $DeployYaml -Value @"
application:
  name: example-service
deployment:
  - requirements:
    - NETFramework451
  - packages:
      NServiceBus.PowerShell:
        version: 4.3.0
        import: lib/net40/NServiceBus.PowerShell.dll
  - permissions:
      .:
        FullControl:
          - sid://BuiltinAdministratorsSid
          - sid://LocalSystemSid
      bin:
        ReadAndExecute:
          - sid://NetworkServiceSid
      logs:
        Modify:
          - sid://NetworkServiceSid
  - custom:
      install: install.ps1
      uninstall: uninstall.ps1
"@

    Invoke-Deployment -Root '.' -ConfigFile $DeployYaml

    It 'installs requirements' {
      Assert-MockCalled -Module Deployment Install-Requirements -ParameterFilter { $Config[0] -eq 'NETFramework451' }
    }

    It 'installs packages' {
      Assert-MockCalled -Module Deployment Install-Packages -ParameterFilter { $Config.'NServiceBus.PowerShell'.version -eq '4.3.0' }
    }

    It 'installs permissions' {
      Assert-MockCalled -Module Deployment Install-Permissions -ParameterFilter { $Config.'.'.FullControl[0] -eq 'sid://BuiltinAdministratorsSid' }
    }

    It 'installs service' {
      Assert-MockCalled -Module Deployment Install-Custom -ParameterFilter { $Config.install -eq 'install.ps1' }
    }
  }
}
