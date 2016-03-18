function Invoke-Installer()
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config
  )

  $Type = $(Get-Culture).TextInfo.ToTitleCase($Config.application.type)
  $Installer = "Install-${Type}Application"

  Write-Host "Invoking $Installer installer from application type $($Config.application.type)"

  & $Installer -Config $Config
}
