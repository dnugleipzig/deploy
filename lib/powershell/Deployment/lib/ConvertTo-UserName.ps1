function ConvertTo-UserName
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Identity
  )

  begin
  {
    Set-Variable -Name SidToken -Value 'sid://' -Option Constant
  }

  process
  {
    if (!$Identity.StartsWith($SidToken, [System.StringComparison]::OrdinalIgnoreCase))
    {
      Return $Identity
    }

    $SID = [System.Security.Principal.WellKnownSidType] $Identity.Substring($SidToken.Length)
    $Account = New-Object System.Security.Principal.SecurityIdentifier($SID, $null)
    $Account.Translate([System.Security.Principal.NTAccount]).Value
  }
}
