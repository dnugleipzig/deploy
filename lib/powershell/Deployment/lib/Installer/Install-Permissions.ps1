function Install-Permissions
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

  $AffectedPaths = $Config.GetEnumerator() | Sort-Object -Property Name | ForEach-Object {
    $Path = $_.Key

    Set-Permission -Path $Path -Permissions $_.Value
    Resolve-Path -Path $Path -ErrorAction SilentlyContinue
  }

  $Path = Get-Location

  $CwdAffected = $AffectedPaths | Where-Object { $_.Path -eq $Path }
  if ($null -eq $CwdAffected)
  {
    Return
  }

  "Removing inherited ACEs from $Path" | Out-Host
  $Inherited = Get-Acl -Path $Path
  $Inherited.SetAccessRuleProtection($true, $false)
  Set-Acl -Path $Path -AclObject $Inherited
}
