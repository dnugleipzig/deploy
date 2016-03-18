function Install-ServiceApplication
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config
  )

  Install-Application -Config $Config

  Install-CustomApplication -Config $Config
}
