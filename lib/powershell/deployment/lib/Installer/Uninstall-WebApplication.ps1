function Uninstall-WebApplication
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config
  )

  Uninstall-CustomApplication -Config $Config
}
