function New-RecreatedWebSite
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Name,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Pool,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $PhysicalPath,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $LogDirectory
  )

  if ($(Test-Path -Path "IIS:\Sites\$Name") -eq $true)
  {
    Write-Host "Removing web site $Name"
    Remove-WebSite -Name $Name
  }

  $PhysicalPath = [System.IO.Path]::GetFullPath($PhysicalPath)
  $LogDirectory = [System.IO.Path]::GetFullPath($LogDirectory)

  Write-Host "Creating web site"
  Write-Host "  Name: $Name"
  Write-Host "  Path: $PhysicalPath"
  Write-Host "  Application pool: $Pool"
  Write-Host "  Logs: $LogDirectory"

  $Site = New-WebSite -Name $Name -ApplicationPool $Pool -PhysicalPath $PhysicalPath
  Set-ItemProperty -Path IIS:\Sites\$Name -Name LogFile.Directory -Value $LogDirectory

  Set-WebConfigurationProperty -Filter "/system.applicationHost/sites/site[@name='$Name']" -PSPath IIS:\ -Name LogFile.LogExtFileFlags -Value 'Date,Time,ClientIP,UserName,ServerIP,Method,UriStem,UriQuery,HttpStatus,Win32Status,TimeTaken,ServerPort,UserAgent,Referer,HttpSubStatus'

  Set-WebConfigurationProperty -Filter /system.webServer/serverRuntime -PSPath MACHINE/WEBROOT/APPHOST -Location $Name -Name frequentHitThreshold -value 1
  Set-WebConfigurationProperty -Filter /system.webServer/serverRuntime -PSPath MACHINE/WEBROOT/APPHOST -Location $Name -Name frequentHitTimePeriod -value $(New-TimeSpan -Days 7)

  Return $Site
}
