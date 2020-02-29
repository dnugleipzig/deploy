$File = Join-Path -Resolve -Path ($PSScriptRoot -Replace 'spec', 'lib') -ChildPath deploy.ps1

Describe 'deploy.ps1' {
  function Invoke-Deployment
  {
    [CmdletBinding()]
    param (
      [string] $RootDirectory,
      [string] $ConfigFile,
      [switch] $Uninstall
    )
  }

  $NotAnAdministrator = $false

  Context 'setup' {
    function Operation { }
    Mock Operation
    Mock Import-Module

    try
    {
      . $File -Operation Operation
    }
    catch [System.Management.Automation.ScriptRequiresException]
    {
      $NotAnAdministrator = $true
    }


    It 'sets default ErrorAction' {
      if ($NotAnAdministrator)
      {
        Set-ItResult -Inconclusive -Because 'needs to be run as an Administrator'
        Return
      }

      $PSDefaultParameterValues.'*:ErrorAction' | Should Be 'Stop'
    }

    It 'imports WebAdministration' {
      if ($NotAnAdministrator)
      {
        Set-ItResult -Inconclusive -Because 'needs to be run as an Administrator'
        Return
      }

      Assert-MockCalled Import-Module -ParameterFilter {
        $Name -eq 'WebAdministration'
      }
    }

     It 'imports Deployment' {
      if ($NotAnAdministrator)
      {
        Set-ItResult -Inconclusive -Because 'needs to be run as an Administrator'
        Return
      }

      Assert-MockCalled Import-Module -ParameterFilter {
        $Name -match 'Deployment' -and
        $NoClobber.IsPresent
      }
    }

    It 'invokes specified operation' {
      if ($NotAnAdministrator)
      {
        Set-ItResult -Inconclusive -Because 'needs to be run as an Administrator'
        Return
      }

      Assert-MockCalled Operation
    }
  }

  Context 'install' {
    Mock Invoke-Deployment
    Mock Import-Module

    try
    {
      . $File -Operation Install
    }
    catch [System.Management.Automation.ScriptRequiresException]
    {
      $NotAnAdministrator = $true
    }

    It 'invokes deployment as install' {
      if ($NotAnAdministrator)
      {
        Set-ItResult -Inconclusive -Because 'needs to be run as an Administrator'
        Return
      }

      Assert-MockCalled Invoke-Deployment -ParameterFilter {
        $RootDirectory -eq (Split-Path $File) -and
        $ConfigFile -eq 'deploy.yaml' -and
        !$Uninstall.IsPresent
      }
    }
  }

  Context 'with custom config file' {
    Mock Invoke-Deployment
    Mock Import-Module

    try
    {
      . $File -Operation Install -ConfigFile 'foo.yaml'
    }
    catch [System.Management.Automation.ScriptRequiresException]
    {
      $NotAnAdministrator = $true
    }

    It 'invokes deployment as install' {
      if ($NotAnAdministrator)
      {
        Set-ItResult -Inconclusive -Because 'needs to be run as an Administrator'
        Return
      }

       Assert-MockCalled Invoke-Deployment -ParameterFilter {
         $RootDirectory -eq (Split-Path $File) -and
         $ConfigFile -eq 'foo.yaml' -and
         !$Uninstall.IsPresent
      }
    }
  }

  Context 'uninstall' {
    Mock Invoke-Deployment
    Mock Import-Module

    try
    {
      . $File -Operation Uninstall
    }
    catch [System.Management.Automation.ScriptRequiresException]
    {
      $NotAnAdministrator = $true
    }

    It 'invokes deployment as uninstall' {
      if ($NotAnAdministrator)
      {
        Set-ItResult -Inconclusive -Because 'needs to be run as an Administrator'
        Return
      }

      Assert-MockCalled Invoke-Deployment -ParameterFilter {
        $RootDirectory -eq (Split-Path $File) -and
        $ConfigFile -eq 'deploy.yaml'-and
        $Uninstall.IsPresent
      }
    }
  }
}
