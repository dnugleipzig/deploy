function Install-Certificates
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

  Set-Variable -Name EnvToken -Value 'env://' -Option Constant

  $Config.GetEnumerator() | ForEach-Object {
    $Params = @{ CertificateFile = $_.Key }

    $Password = $_.Value
    if ($null -ne $Password -and $Password.StartsWith($EnvToken, [System.StringComparison]::OrdinalIgnoreCase))
    {
      $Key = $Password.Substring($EnvToken.Length)
      $Password = (Get-ChildItem -Path env:$Key).Value
    }

    if($null -ne $Password)
    {
      $Params.Password = $Password
    }

    Install-Certificate @Params
  }
}
