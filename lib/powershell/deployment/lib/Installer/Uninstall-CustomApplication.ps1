function Uninstall-CustomApplication
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config,
    [Parameter(Position = 1, Mandatory = $false)]
    [string] $File = '.\deploy-uninstall.ps1'
  )

  if (Test-Path -Path $File -PathType Leaf)
  {
    Write-Host "Running custom uninstaller from $File"
    & $File -Config $Config
  }
}
