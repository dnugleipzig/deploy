function Install-Certificate()
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Certificate,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Password
  )

  $Flags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet -bor `
           [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet -bor `
           [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
  $Certs = New-Object Security.Cryptography.X509Certificates.X509Certificate2Collection
  $Certs.Import($Certificate, $Password, $Flags)

  $Certs | ForEach-Object {
    $StoreLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine
    $StoreName = [System.Security.Cryptography.X509Certificates.StoreName]::CertificateAuthority
    $IisBinding = {}

    if ($_.HasPrivateKey -eq $true)
    {
      $StoreName = [System.Security.Cryptography.X509Certificates.StoreName]::My
      $IisBinding = {
        param (
          [Parameter(Mandatory = $true)]
          [ValidateNotNullOrEmpty()]
          [Security.Cryptography.X509Certificates.X509Certificate2] $Certificate
        )
        Write-Host "Setting up IIS SSL bindings for $($Certificate.Subject)"
        Remove-Item IIS:\SslBindings\0.0.0.0!443 -ErrorAction:SilentlyContinue
        $Certificate | New-Item IIS:\SslBindings\0.0.0.0!443 | Out-Null
      }
    }

    try
    {
      $Cert = $_

      $Store = New-Object System.Security.Cryptography.X509Certificates.X509Store($StoreName, $StoreLocation)
      $Store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)

      $Installed = $Store.Certificates | Where-Object { $Cert.Thumbprint -eq  $_.Thumbprint } | Select-Object -First 1
      if($Installed -eq $null)
      {
        Write-Host "Installing certificate $($_.Subject) to $StoreLocation\$StoreName"
        $Store.Add($_)
      }
      else
      {
        Write-Host "Certificate $($_.Subject) is already installed in $StoreLocation\$StoreName"
      }
      & $IisBinding $_
    }
    finally
    {
      $Store.Close()
    }
  }
}
