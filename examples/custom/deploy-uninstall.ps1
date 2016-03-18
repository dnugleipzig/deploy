[CmdletBinding()]
param(
  [Parameter(Position = 0, Mandatory = $true)]
  [ValidateNotNull()]
  [hashtable] $Config
)

Write-Host "Custom uninstaller"
Write-Host $Config.deployment.application
Write-Host $Config.application.type
