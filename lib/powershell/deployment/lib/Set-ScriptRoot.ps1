function Set-ScriptRoot
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string] $Root
  )

  $Root = Convert-Path $Root

  Write-Host "Setting script root to $Root"
  Set-Location $Root

  # Required for NuGet download.
  [System.IO.Directory]::SetCurrentDirectory($Root)

  Return $Root
}
