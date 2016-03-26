$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'ConvertTo-UserName' {
  InModuleScope Deployment {
    Context 'valid SID' {
      It 'returns user name' {
        $Name = ConvertTo-UserName -Identity 'sid://BuiltinAdministratorsSid'

        $Name | Should Match 'BUILTIN\\'
      }

      It 'supports piping' {
        $Name = 'sid://BuiltinAdministratorsSid' | ConvertTo-UserName

        $Name | Should Match 'BUILTIN\\'
      }
    }

    Context 'invalid SID' {
      It 'fails' {
        { ConvertTo-UserName -Identity 'sid://NoSid' } | Should Throw 'Cannot convert value'
      }
    }

    Context 'user name' {
      It 'returns user name as-is' {
        $Name = ConvertTo-UserName -Identity 'user'

        $Name | Should Be 'user'
      }

      It 'supports piping' {
        $Name = 'user' | ConvertTo-UserName

        $Name | Should Be 'user'
      }
    }

    Context 'mixed piping' {
      It 'succeeds' {
        $Names = @('sid://BuiltinAdministratorsSid', 'user') | ConvertTo-UserName

        $Names[0] | Should Match 'BUILTIN\\'
        $Names[1] | Should Be 'user'
      }
    }
  }
}
