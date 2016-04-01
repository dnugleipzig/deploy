function Install-Requirements
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [AllowEmptyCollection()]
    [array] $Config,
    [switch] $Uninstall
  )

  if ($Uninstall.IsPresent)
  {
    Return
  }

  if ($Config.Count -eq 0)
  {
    Return
  }

  $LogFile = [System.IO.Path]::GetTempFileName()

  try
  {
    Exec {
      & .\tools\webpi\WebpiCmd.exe `
        /Install `
        "/Products:$($Config -Join ',')" `
        /SuppressReboot `
        /AcceptEula `
        "/Log:$LogFile"
    }
  }
  finally
  {
    Remove-Item -Path $LogFile -ErrorAction SilentlyContinue
  }
}
