function Get-Config()
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $File
  )

  $File = [System.IO.Path]::GetFullPath($File)

  Write-Host "Reading config from $File"
  $(Get-Content -Path $File -Raw) | ConvertFrom-Json | ConvertTo-Hashtable
}
