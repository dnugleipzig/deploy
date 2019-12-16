function Test-HttpResponse
{
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [hashtable[]] $Tests
  )

  if ($null -eq $Tests -or $Tests.Count -eq 0)
  {
    Return
  }

  'Testing HTTP responses' | Out-Host

  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls13 -bor `
    [System.Net.SecurityProtocolType]::Tls12 -bor `
    [System.Net.SecurityProtocolType]::Tls11 -bor `
    [System.Net.SecurityProtocolType]::Tls

  $Tests | ForEach-Object {
    $Method = $_.method
    $Url = $_.url
    $ExpectedStatus = $_.expect.status
    $ExpectedUrl = $_.expect.url
    $Response = $null

    "  $Method $Url -> $ExpectedStatus $ExpectedUrl" | Out-Host

    $Request = [System.Net.HttpWebRequest]::Create($Url)
    $Request.AllowAutoRedirect = $true
    $Request.Method = $Method
    if ($Request.Method -eq 'POST' -and $_.ContainsKey('data'))
    {
      $Request.ContentType = "application/x-www-form-urlencoded"
      $Stream = $Request.GetRequestStream()
      $Encoded = [System.Text.Encoding]::UTF8.GetBytes($_.data)
      $Stream.Write($Encoded, 0, $Encoded.Length)
      $Stream.Close()
    }

    try
    {
      $Response = $Request.GetResponse()
      $Status = $Response.StatusCode
      $Url = $Response.ResponseUri.ToString()

      if ($Status -ne $ExpectedStatus)
      {
        throw "Expected HTTP status code $ExpectedStatus, but got $Status"
      }

      if ($Url -ne $ExpectedUrl)
      {
        throw "Expected location $ExpectedUrl, but got $Url"
      }
    }
    finally
    {
      if ($null -ne $Response)
      {
        $Response.Close()
      }
    }
  }
}
