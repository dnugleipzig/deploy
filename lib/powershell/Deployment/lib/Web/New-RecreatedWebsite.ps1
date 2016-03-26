function New-RecreatedWebsite
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Name,
    [Parameter(Position = 1, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Pool,
    [Parameter(Position = 2, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $PhysicalPath,
    [Parameter(Position = 3, Mandatory = $false)]
    [hashtable] $Properties
  )

  if (Test-Path -Path IIS:\Sites\$Name)
  {
    "Removing web site $Name" | Out-Host
    Remove-Website -Name $Name
  }

  $Params = [ordered]@{
    Name = $Name
    ApplicationPool = $Pool
    PhysicalPath = Resolve-Path -Path $PhysicalPath
  }

  'Creating web site' | Out-Host
  $Site = New-Website @Params
  $Site | Format-List | Out-String -Width 200 | Out-Host

  $DefaultProperties = @(
    @{
      Filter = "/system.applicationHost/sites/site[@name='$($Site.Name)']"
      PSPath = 'IIS:\'
      Name = 'LogFile.LogExtFileFlags'
      Value = 'Date,Time,ClientIP,UserName,ServerIP,Method,UriStem,UriQuery,HttpStatus,Win32Status,TimeTaken,ServerPort,UserAgent,Referer,HttpSubStatus'
      WarningAction = 'Stop'
    },
    @{
      Filter = '/system.webServer/serverRuntime'
      PSPath = 'MACHINE/WEBROOT/APPHOST'
      Location = $Site.Name
      Name = 'frequentHitThreshold'
      Value = 1
      WarningAction = 'Stop'
    },
    @{
      Filter = '/system.webServer/serverRuntime'
      PSPath = 'MACHINE/WEBROOT/APPHOST'
      Location = $Site.Name
      Name = 'frequentHitTimePeriod'
      Value = New-TimeSpan -Days 7
      WarningAction = 'Stop'
    }
  )

  $DefaultProperties | ForEach-Object {
    Set-WebConfigurationProperty @_
  }

  $Properties | Expand-Hashtable | ForEach-Object {
    $Name = ($_.Path | ConvertTo-PascalCase) -Join '.'
    $Value = $_.Value | ConvertTo-AbsolutePath

    "Setting property $Name to $Value" | Out-Host

    $Config = @{
      Filter = "/system.applicationHost/sites/site[@name='$($Site.Name)']"
      PSPath = 'IIS:\'
      Name = $Name
      Value = $Value
      WarningAction = 'Stop'
    }

    Set-WebConfigurationProperty @Config
  }

  Return $Site
}
