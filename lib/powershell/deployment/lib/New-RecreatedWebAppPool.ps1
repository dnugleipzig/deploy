function New-RecreatedWebAppPool
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Name,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Identity,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Runtime
  )

  if ($(Test-Path -Path "IIS:\AppPools\$Name") -eq $true)
  {
    Write-Host "Removing application pool $Name"
    Remove-WebAppPool -Name $Name
  }

  Write-Host "Creating application pool $Name"

  $Pool = New-WebAppPool -Name $Name
  $Pool.ProcessModel.IdentityType = $Identity
  $Pool.ManagedRuntimeVersion = $Runtime
  $Pool | Set-Item

  Return $Pool
}
