#Requires -Version 4.0
#Requires -RunAsAdministrator
#Requires -Modules WebAdministration

[CmdletBinding()]
param(
  [Parameter(Position = 0, Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $Operation
)

$PSDefaultParameterValues += @{ '*:ErrorAction' = 'Stop' }

Import-Module -Name WebAdministration
Import-Module -Name "$PSScriptRoot\lib\Deployment" -NoClobber

Set-ScriptRoot -Root $PSScriptRoot | Out-Null

function Install
{
  $Config = Get-Config -File 'deploy.json'
  Invoke-Installer -Config $Config
}

function Uninstall {
  $Config = Get-Config -File 'deploy.json'
  Invoke-Uninstaller -Config $Config
}

& $Operation
