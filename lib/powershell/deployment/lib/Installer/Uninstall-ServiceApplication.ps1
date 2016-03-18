function Uninstall-ServiceApplication
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config
  )

  Uninstall-CustomApplication -File '.\deploy-uninstall.ps1' -Config $Config
}
