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
      $Account = New-Object System.Security.Principal.NTAccount($Identity)
      [void] $Account.Translate([System.Security.Principal.SecurityIdentifier])
    }
    else
    {
      $Identity = $Identity.Substring($SidToken.Length)

      if([System.Enum]::GetValues([System.Security.Principal.WellKnownSidType]) -contains $Identity)
      {
        $SID = [System.Security.Principal.WellKnownSidType] $Identity
        $Account = New-Object System.Security.Principal.SecurityIdentifier($SID, $null)
      }
      else
      {
        $Account = New-Object System.Security.Principal.SecurityIdentifier($Identity)
      }
    }

    $Account.Translate([System.Security.Principal.NTAccount]).Value
  }
}
