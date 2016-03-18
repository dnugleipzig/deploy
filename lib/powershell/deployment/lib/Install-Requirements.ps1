function Install-Requirements()
{
  <#
    .EXAMPLE
      $Requirements = @(
        'NETFramework451'
        'UrlRewrite2'
      )

      Install-Requirements -Requirements $Requirements
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [array] $Requirements
  )

  if ($Requirements -eq $null -or $Requirements.Length -eq 0)
  {
    Return
  }

  Exec {
    & '.\tools\webpi\WebpiCmd.exe' `
      '/Install' `
      "/Products:$($Requirements -Join ',')" `
      '/SuppressReboot' `
      '/AcceptEula'
  }
}
