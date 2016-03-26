function Install-Web
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config,
    [switch] $Uninstall
  )

  if ($Uninstall.IsPresent)
  {
    "Stopping web site $($Config.name)" | Out-Host
    Stop-Website -Name $Config.name

    Return
  }

  $Pool = New-RecreatedWebAppPool -Name $Config.app_pool.name `
                                  -Properties $Config.app_pool.properties

  $Site = New-RecreatedWebsite -Name $Config.name  `
                               -Pool $Pool.Name `
                               -PhysicalPath $Config.physical_path `
                               -Properties $Config.properties

  Install-WebBindings -Site $Site.Name -Bindings $Config.bindings

  Start-Website -Name $Site.Name

  Test-HttpResponse -Tests $Config.tests
}
