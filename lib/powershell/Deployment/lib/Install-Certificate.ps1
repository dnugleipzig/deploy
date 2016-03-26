function Install-Certificate()
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $CertificateFile,

    [Parameter(Position = 1, Mandatory = $false)]
    [string] $Password
  )

  $Flags = [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::MachineKeySet -bor `
           [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet -bor `
           [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
  $StoreLocation = [System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine

  $Certs = New-Object Security.Cryptography.X509Certificates.X509Certificate2Collection
  $Certs.Import($CertificateFile, $Password, $Flags)

  $Certs | ForEach-Object {
    $StoreName = [System.Security.Cryptography.X509Certificates.StoreName]::CertificateAuthority
    $IisBinding = [scriptblock] { param ($Certificate) }

    if ($_.HasPrivateKey -eq $true)
    {
      $StoreName = [System.Security.Cryptography.X509Certificates.StoreName]::My
      $IisBinding = [scriptblock] {
        param (
          [Parameter(Position = 0, Mandatory = $true)]
          [ValidateNotNullOrEmpty()]
          [Security.Cryptography.X509Certificates.X509Certificate2] $Certificate
        )
        "Setting up IIS SSL bindings for $($Certificate.Subject)" | Out-Host
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
      if($null -eq $Installed)
      {
        "Installing certificate $($_.Subject) to $StoreLocation\$StoreName" | Out-Host
        $Store.Add($_)
      }
      else
      {
        "Certificate $($_.Subject) is already installed in $StoreLocation\$StoreName" | Out-Host
      }
      & $IisBinding -Certificate $_
    }
    finally
    {
      $Store.Close()
    }
  }
}
