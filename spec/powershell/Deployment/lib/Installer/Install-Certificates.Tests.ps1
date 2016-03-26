$Module = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath ..\..\Deployment.psm1
Import-Module -Name $Module

Describe 'Install-Certificates' {
  InModuleScope Deployment {
    Mock Install-Certificate

    Context 'no certificates' {
      Install-Certificates -Config @{}

      It 'does not install certificates' {
        Assert-MockCalled Install-Certificate -Exactly 0
      }
    }

    Context 'certificates to install' {
      $Config = @{
        'with-password' = 'password'
        'with-password-from-env' = 'env://password'
        'without-password' = $null
      }

      try
      {
        $env:Password = 'password from env'
        Install-Certificates -Config $Config
      }
      finally
      {
        Remove-Item -Path env:Password
      }

      It 'installs certificate with password' {
        Assert-MockCalled Install-Certificate -ParameterFilter { $CertificateFile -eq 'with-password' -and $Password -eq $Config.'with-password' }
      }

      It 'installs certificate with password from environment variable' {
        Assert-MockCalled Install-Certificate -ParameterFilter { $CertificateFile -eq 'with-password-from-env' -and $Password -eq 'password from env' }
      }

      It 'installs certificate without password' {
        Assert-MockCalled Install-Certificate -ParameterFilter { $CertificateFile -eq 'without-password' -and $Password -eq $Config.'without-password' }
      }
    }

    Context 'uninstall' {
      $Config = @{
        something = $null
      }

      Install-Certificates -Config $Config -Uninstall

      It 'does not uninstall certificates' {
        Assert-MockCalled Install-Certificate -Exactly 0
      }
    }
  }
}
