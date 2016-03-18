function Install-Packages
{
  <#
    .EXAMPLE
      $Packages = @{
        'Carbon' = @{
          'Version' = '2.1.1'
          'Import' = 'Carbon/Carbon'
        }
      }

      Install-Packages -Packages $Packages -Import {
        param($ModulePath)
        Import-Module $ModulePath
      }
  #>
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $false)]
    [hashtable] $Packages,
    [Parameter(Position = 1, Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $OutputDirectory = '.\lib',
    [Parameter(Position = 2, Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $NuGetPath = '.\tools\nuget',
    [Parameter(Position = 3, Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $NuGetUri = 'https://www.nuget.org/nuget.exe',
    [Parameter(Position = 4, Mandatory = $false)]
    [scriptblock] $Import
  )

  if ($Packages -eq $null -or $Packages.Count -eq 0)
  {
    Return
  }

  $OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
  $NuGetPath = Join-Path $([System.IO.Path]::GetFullPath($NuGetPath)) 'nuget.exe'

  if($(Test-Path $NuGetPath) -eq $false) {
    Write-Host "Downloading nuget.exe to $NuGetPath"

    $Parent = Split-Path -Parent $NuGetPath
    New-Item -ItemType Directory -Path $Parent -Force | Out-Null

    try {
      Invoke-WebRequest -Uri $NuGetUri -OutFile $NuGetPath
    }
    catch {
      throw "Could not download NuGet from $NuGetUri to $($NuGetPath): $($_.Exception.Message)"
    }
  }

  $Packages.GetEnumerator() | `
    ForEach-Object {
      Write-Host "Downloading $($_.Key) version $($_.Value.Version) to $OutputDirectory"

      Exec {
        & "$NuGetPath" install $_.Key `
        -Version $_.Value.Version `
        -OutputDirectory "$OutputDirectory" `
        -ExcludeVersion `
        -NonInteractive
      }

      if ($_.Value.Import -ne $null) {
        $ModulePath = Join-Path $(Join-Path $OutputDirectory $_.Key) $_.Value.Import

        Invoke-Command $Import -ArgumentList $ModulePath
      }
    }
}
