function Install-CustomApplication
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config,
    [Parameter(Position = 1, Mandatory = $false)]
    [string] $File = '.\deploy-install.ps1'
  )

  if (Test-Path -Path $File -PathType Leaf)
  {
    Write-Host "Running custom installer from $File"
    & $File -Config $Config
  }
}
