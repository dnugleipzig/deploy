function Install-Package
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Id,
    [Parameter(Position = 1, Mandatory = $false)]
    [string] $Version,
    [Parameter(Position = 2, Mandatory = $false)]
    [string[]] $Import,
    [Parameter(Position = 3, Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $OutputDirectory = '.\lib'
  )

  begin
  {
    $NuGet = Find-NuGet
  }

  process
  {
    "Downloading $Id version $(if([String]::IsNullOrEmpty($Version)) { 'latest' } else { $Version }) to $OutputDirectory" | Out-Host

    $VersionSpecifier = $null
    if ([String]::IsNullOrEmpty($Version))
    {
      $VersionSpecifier = @('-Version', $Version)
    }

    Exec {
      & "$NuGet" install $Id `
        @VersionSpecifier `
        -OutputDirectory "$OutputDirectory" `
        -ExcludeVersion `
        -NonInteractive
    }

    if($null -eq $Import)
    {
      Return
    }

    $Import | ForEach-Object {
      $ModulePath = Join-Path $(Join-Path $OutputDirectory $Id) $_

      Import-Module -Name $ModulePath
    }
  }
}
