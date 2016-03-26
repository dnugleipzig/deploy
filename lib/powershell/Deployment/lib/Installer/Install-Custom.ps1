function Install-Custom
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config,
    [switch] $Uninstall
  )

  $File = $null

  if ($Uninstall.IsPresent)
  {
    if($Config.ContainsKey('uninstall'))
    {
      $File = $Config.uninstall
    }
  }
  elseif($Config.ContainsKey('install'))
  {
    $File = $Config.install
  }

  if ($null -eq $File)
  {
    Return
  }

  $File = Convert-Path -Path $File -ErrorAction Stop
  if ((Test-Path -Path $File -PathType Leaf) -eq $false)
  {
    throw "Custom script $File is not a file"
  }

  "Running custom script $File" | Out-Host
  & $File -Config $Config
}
