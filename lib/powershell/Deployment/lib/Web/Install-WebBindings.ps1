function Install-WebBindings
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Site,
    [Parameter(Position = 1, Mandatory = $false)]
    [hashtable[]] $Bindings
  )

  "Removing default bindings for web site $Site" | Out-Host
  Get-WebBinding -Name $Site | Remove-WebBinding

  if ($null -eq $Bindings -or $Bindings.Count -eq 0)
  {
    Return
  }

  "Installing bindings for web site ${Site}:" | Out-Host
  $Bindings | ForEach-Object {
    $Binding = @{ Name = $Site }

    $_.GetEnumerator() | ForEach-Object {
      $Binding.Add($(ConvertTo-PascalCase $_.Key), $_.Value)
    }

    $Binding | Format-Table -HideTableHeaders | Out-Host
    New-WebBinding @Binding
  }
}
