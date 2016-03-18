function ConvertTo-UserName
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [System.Security.Principal.WellKnownSidType] $SID
  )

  $Account = New-Object System.Security.Principal.SecurityIdentifier($SID, $null)
  Return $Account.Translate([System.Security.Principal.NTAccount]).Value
}
