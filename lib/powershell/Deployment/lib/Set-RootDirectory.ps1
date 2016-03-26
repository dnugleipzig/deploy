function Set-RootDirectory
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string] $Path
  )

  $Path = Convert-Path -Path $Path -ErrorAction Stop

  "Setting root directory to $Path" | Out-Host
  Set-Location -Path $Path

  # Required for NuGet download.
  [System.IO.Directory]::SetCurrentDirectory($Path)
}
