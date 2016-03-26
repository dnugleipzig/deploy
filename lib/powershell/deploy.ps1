#Requires -Version 4.0
#Requires -RunAsAdministrator

[CmdletBinding()]
param(
  [Parameter(Position = 0, Mandatory = $true)]
  [ValidateNotNullOrEmpty()]
  [string] $Operation,
  [Parameter(Position = 1, Mandatory = $false)]
  [string] $ConfigFile = 'deploy.yaml'
)

$PSDefaultParameterValues += @{ '*:ErrorAction' = 'Stop' }

Import-Module -Name WebAdministration
Import-Module -Name "$PSScriptRoot\lib\Deployment\Deployment" -NoClobber

function Install
{
  Invoke-Deployment -RootDirectory $PSScriptRoot -ConfigFile $ConfigFile
}

function Uninstall {
  Invoke-Deployment -RootDirectory $PSScriptRoot -ConfigFile $ConfigFile -Uninstall
}

& $Operation
