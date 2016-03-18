function Install-WebApplication
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config
  )

  Install-Application -Config $Config

  $Pool = New-RecreatedWebAppPool -Name $Config.application.app_pool.name -Identity $Config.application.app_pool.identity -Runtime $Config.application.app_pool.runtime
  $Site = New-RecreatedWebSite -Name $Config.application.name -Pool $Pool.Name -PhysicalPath $Config.application.physical_path -LogDirectory $Config.application.logs
  Install-WebBindings -Site $Site.Name -Bindings $Config.application.bindings

  Install-CustomApplication -File '.\deploy-install.ps1' -Config $Config

  Start-Website -Name $Site.Name

  Test-HttpResponse -Tests $Config.application.tests
}
