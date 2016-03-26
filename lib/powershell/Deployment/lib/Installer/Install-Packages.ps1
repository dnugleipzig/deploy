function Install-Packages
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNull()]
    [hashtable] $Config,
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

  $Config.GetEnumerator() | ForEach-Object {
    $Params = @{ Id = $_.Key }

    if ($null -ne $_.Value)
    {
      if ($_.Value.ContainsKey('version'))
      {
        $Params.Version = $_.Value.version
      }

      if ($_.Value.ContainsKey('import'))
      {
        $Params.Import = $_.Value.import
      }
    }

    Install-Package @Params
  }
}
