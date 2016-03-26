function New-RecreatedWebAppPool
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Name,
    [Parameter(Position = 1, Mandatory = $false)]
    [hashtable] $Properties
  )

  if (Test-Path -Path IIS:\AppPools\$Name)
  {
    "Removing application pool $Name" | Out-Host
    Remove-WebAppPool -Name $Name
  }

  'Creating application pool' | Out-Host
  $Pool = New-WebAppPool -Name $Name
  $Pool | Format-List | Out-String -Width 200 | Out-Host

  $Properties | Expand-Hashtable | ForEach-Object {
    $Name = ($_.Path | ConvertTo-PascalCase) -Join '.'
    $Value = $_.Value | ConvertTo-AbsolutePath

    "Setting property $Name to $Value" | Out-Host

    $Config = @{
      Filter = "/system.applicationHost/applicationPools/add[@name='$($Pool.Name)']"
      PSPath = 'IIS:\'
      Name = $Name
      Value = $Value
      WarningAction = 'Stop'
    }

    Set-WebConfigurationProperty @Config
  }

  Return $Pool
}
