function Install-Application
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config
  )

  Install-Requirements -Requirements $Config.requirements

  Install-Packages -Packages $Config.packages -Import {
    param($ModulePath)
    Import-Module $ModulePath
  }

  Set-Permissions -RootPath '.' -Permissions $Config.permissions

  Install-Certificates -Certificates $Config.certificates
}
