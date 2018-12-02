$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\Deployment.psm1
Import-Module -Name $Module

Describe 'ConvertTo-UserName' {
  InModuleScope Deployment {
    Context 'valid SID enum value' {
      It 'returns user name' {
        $Name = ConvertTo-UserName -Identity 'sid://BuiltinAdministratorsSid'

        $Name | Should Match 'BUILTIN\\'
      }

      It 'supports piping' {
        $Name = 'sid://BuiltinAdministratorsSid' | ConvertTo-UserName

        $Name | Should Match 'BUILTIN\\'
      }
    }

    Context 'valid SID in SDDL form' {
      It 'returns user name' {
        $Name = ConvertTo-UserName -Identity 'sid://S-1-5-6'

        $Name | Should Match 'NT AUTHORITY\\'
      }

      It 'supports piping' {
        $Name = 'sid://S-1-5-6' | ConvertTo-UserName

        $Name | Should Match 'NT AUTHORITY\\'
      }
    }

    Context 'invalid SID enum value' {
      It 'fails' {
        { ConvertTo-UserName -Identity 'sid://does-not-exist' } | Should Throw 'Value was invalid'
      }
    }

    Context 'invalid SID in SDDL form' {
      It 'fails' {
        { ConvertTo-UserName -Identity 'sid://S-42-23' } | Should Throw 'Value was invalid'
      }
    }

    Context 'valid user name' {
      It 'returns user name' {
        $Name = ConvertTo-UserName -Identity 'Administrator'

        $Name | Should Be 'Administrator'
      }

      It 'supports piping' {
        $Name = 'Administrator' | ConvertTo-UserName

        $Name | Should Be 'Administrator'
      }
    }

    Context 'invalid user name' {
      It 'fails' {
        { ConvertTo-UserName -Identity 'does-not-exist' } | Should Throw 'Some or all identity references could not be translated'
      }
    }

    Context 'mixed piping' {
      It 'succeeds' {
        $Names = @('sid://BuiltinAdministratorsSid', 'sid://S-1-5-6') | ConvertTo-UserName

        $Names[0] | Should Match 'BUILTIN\\'
        $Names[1] | Should Match 'NT AUTHORITY\\'
      }
    }
  }
}
