function Install-WebBindings
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Site,
    [Parameter(Position = 1, Mandatory = $false)]
    [array] $Bindings
  )

  if ($Bindings -eq $null -or $Bindings.Length -eq 0)
  {
    Return
  }

  Get-WebBinding -Name $Site | Remove-WebBinding

  Write-Host "Installing bindings for web site ${Site}:"
  $Bindings | ForEach-Object {
    Write-Host "  $($_.protocol): $($_.host_header)"
    New-WebBinding -Name $Site -Protocol $_.protocol -HostHeader $_.host_header
  }
}
