[CmdletBinding()]
param(
  [Parameter(Position = 0, Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [hashtable] $Config
)

Write-Host "Custom installer"
Write-Host $Config.deployment.application
Write-Host $Config.application.type
