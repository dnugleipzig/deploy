function Install-Certificates()
{
  <#
    .EXAMPLE
      $Certificates = @{
       'some.pfx' = 'inline password'
       'other.pfx' = 'env://ENV_VAR_WITH_PASSWORD'
      }

      Install-Certificates -Certificates $Certificates
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [hashtable] $Certificates
  )

  if ($Certificates -eq $null -or $Certificates.Count -eq 0)
  {
    Return
  }

  Set-Variable -Name EnvToken -Value 'env://' -Option Constant

  $Certificates.GetEnumerator() | ForEach-Object {
    $Password = $_.Value
    if ($Password.StartsWith($EnvToken, [System.StringComparison]::OrdinalIgnoreCase))
    {
      $Key = $Password.Substring($EnvToken.Length)
      $Password = (Get-ChildItem -Path env:$Key).Value
    }

    Install-Certificate -Certificate $_.Key -Password $Password
  }
}
