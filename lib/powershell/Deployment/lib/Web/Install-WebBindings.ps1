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

  "Associating SSL certificates for web site ${Site}" | Out-Host
  Get-WebBinding -Name $Site -Protocol https | ForEach-Object {
    $Binding = $_
    $Binding | Format-List | Out-Host

    $HostHeader = $Binding.GetAttributeValue('bindingInformation').Split(':') | Select-Object -Last 1

    "Searching certificate for host header $HostHeader" | Out-Host
    $AssociatedCert = Get-ChildItem -Path Cert:\LocalMachine\My | `
      Where-Object {
        $_.Extensions | `
          Where-Object { $_.Oid.FriendlyName -eq 'subject alternative name' } | `
          Where-Object { $_.Format(1) -match "DNS Name=$HostHeader" }
      } | `
      Sort-Object -Property NotAfter -Descending | `
      Select-Object -First 1

    if ($null -eq $AssociatedCert) {
      throw "No certificate found for host header $HostHeader"
    }

    "Found certificate:`n$AssociatedCert" | Out-Host
    $Binding.AddSslCertificate($AssociatedCert.GetCertHashString(), 'My')
  }
}
