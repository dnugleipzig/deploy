function Get-Config()
{
  [CmdletBinding()]
  [OutputType([hashtable])]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $File
  )

  $File = Convert-Path -Path $File -ErrorAction Stop

  "Reading config from $File" | Out-Host
  Import-Module -Name $PSScriptRoot\..\..\PowerYaml\PowerYaml
  Get-Content -Path $File -Raw -ErrorAction Stop | ConvertFrom-Yaml | ConvertTo-Hashtable
}
