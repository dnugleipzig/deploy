function Invoke-Uninstaller()
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config
  )

  $Type = $(Get-Culture).TextInfo.ToTitleCase($Config.application.type)
  $Uninstaller = "Uninstall-${Type}Application"

  Write-Host "Invoking $Uninstaller uninstaller from application type $($Config.application.type)"

  & $Uninstaller -Config $Config
}
