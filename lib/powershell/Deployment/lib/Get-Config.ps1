function Get-Config()
{
  [CmdletBinding()]
  [OutputType([hashtable])]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $File
  )

  $File = Convert-Path -Path $File -ErrorAction Stop

  "Reading config from $File" | Out-Host

  Add-Type -Path $PSScriptRoot\YamlDotNet.dll
  $Yaml = Get-Content -Path $File -Raw -ErrorAction Stop
  $Reader = $null
  try
  {
    $Reader = New-Object System.IO.StringReader($Yaml)
    $Deserializer = New-Object YamlDotNet.Serialization.Deserializer($null, $null, $false)

    $Deserializer.Deserialize($Reader) | ConvertTo-Hashtable
  }
  finally
  {
    if ($null -ne $Reader)
    {
      $Reader.Close()
    }
  }
}
