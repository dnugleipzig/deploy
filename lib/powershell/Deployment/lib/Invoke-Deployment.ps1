function Invoke-Deployment()
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $RootDirectory,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $ConfigFile,
    [switch] $Uninstall
  )

  Set-RootDirectory -Path $RootDirectory

  $Config = Get-Config -File $ConfigFile

  if(!$Config.ContainsKey('deployment'))
  {
    Return
  }

  $Deployment = $Config.deployment
  if ($Deployment -is [array])
  {
    $Deployment = @($Deployment)
  }

  if ($Uninstall)
  {
    [System.Array]::Reverse($Deployment)
  }

  $Deployment | ForEach-Object {
    $_.GetEnumerator() | ForEach-Object {
      $Type = $(Get-Culture).TextInfo.ToTitleCase($_.Key)
      $Installer = "Install-${Type}"

      "Invoking $Installer $(if ($Uninstall.IsPresent) { 'un' })installer" | Out-Host
      try {
        & $Installer -Config $_.Value -Uninstall:$Uninstall.IsPresent
      }
      catch {
        if (!$Uninstall.IsPresent)
        {
          throw
        }
        Write-Error -Message $_ -ErrorAction Continue
      }
    }
  }
}
