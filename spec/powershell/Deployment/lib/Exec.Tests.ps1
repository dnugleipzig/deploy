$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'Exec' {
  InModuleScope Deployment {
    Context 'command returns with exit code 0' {
      function DoSomething { }

      $LastExitCode = 0
      Exec -Command { }

      It 'succeeds' {
        $true | Should Be $true
      }
    }

    Context 'command fails' {
      $LastExitCode = 42

      It 'fails' {
        { Exec -Command { } } | Should Throw 'Exec: Error executing command'
      }
    }

    Context 'sample command' {
      $Cmd = 'cmd.exe'

      It 'succeeds' {
        Exec -Command {
          & $Cmd /c echo hello
        }
      }

      It 'fails' {
        {
          Exec -Command {
            & $Cmd /c /unknown-parameter
          }
        } | Should Throw
      }
    }
  }
}
