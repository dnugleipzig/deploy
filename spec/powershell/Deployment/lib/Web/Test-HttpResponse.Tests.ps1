$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'Test-HttpResponse' {
  InModuleScope Deployment {
    Mock Out-Host

    Context 'null tests' {
      $Tests = $null

      Test-HttpResponse -Tests $Tests

      It 'succeeds' {
        $true | Should Be $true
      }
    }

    Context 'no bindings' {
      $Tests = $null

      Test-HttpResponse -Tests $Tests

      It 'succeeds' {
        $true | Should Be $true
      }
    }

    Context 'tests' {
      $Tests = @(
        @{
          method = 'GET'
          url = 'http://example.com/'
          expect = @{
            status = 200
            url = 'http://example.com/'
          }
        },
        @{
          method = 'POST'
          url = 'http://example.com/'
          data = 'test data'
          expect = @{
            status = 200
            url = 'http://example.com/'
          }
        }
      )

      Test-HttpResponse -Tests $Tests

      It 'succeeds' {
        $true | Should Be $true
      }
    }

    Context 'POST without data' {
      $Tests = @(
        @{
          method = 'POST'
          url = 'http://example.com/'
          expect = @{
            status = 200
            url = 'http://example.com/'
          }
        }
      )

      It 'fails' {
        { Test-HttpResponse -Tests $Tests } | Should Throw '411'
      }
    }

    Context 'request fails' {
      $Tests = @(
        @{
          method = 'GET'
          url = 'http://i.will.never.exits.example/'
          expect = @{
            status = 200
            url = 'http://example.com/'
          }
        }
      )

      It 'fails' {
        { Test-HttpResponse -Tests $Tests } | Should Throw 'i.will.never.exits.example'
      }
    }

    Context 'result URL does not match expectation' {
      $Tests = @(
        @{
          method = 'GET'
          url = 'http://example.com/'
          expect = @{
            status = 200
            url = 'http://i.will.never.exits.example/'
          }
        }
      )

      It 'fails' {
        { Test-HttpResponse -Tests $Tests } | Should Throw 'Expected location http://i.will.never.exits.example/, but got'
      }
    }

    Context 'status  does not match expectation' {
      $Tests = @(
        @{
          method = 'GET'
          url = 'http://example.com/'
          expect = @{
            status = 404
            url = 'http://example.com/'
          }
        }
      )

      It 'fails' {
        { Test-HttpResponse -Tests $Tests } | Should Throw 'Expected HTTP status code 404, but got'
      }
    }
  }
}
