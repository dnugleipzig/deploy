function Find-NuGet
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $Path = '.\tools\nuget\nuget.exe',
    [Parameter(Position = 1, Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $DownloadFrom = 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe'
  )

  if(Test-Path $Path)
  {
    Return $Path
  }

  "Downloading NuGet to $Path" | Out-Host

  $Parent = Split-Path -Parent $Path
  New-Item -ItemType Directory -Path $Parent -Force | Out-Null

  try
  {
    Invoke-WebRequest -Uri $DownloadFrom -OutFile $Path
  }
  catch
  {
    throw "Could not download NuGet from $DownloadFrom to ${Path}: $($_.Exception.Message)"
  }

  $Path
}
