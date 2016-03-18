function Test-HttpResponse {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $false)]
    [array] $Tests
  )

  if ($Tests -eq $null -or $Tests.Length -eq 0)
  {
    Return
  }

  Write-Host "Testing HTTP responses:"

  $Tests | ForEach-Object {
    $Method = $_.method
    $Url = $_.url
    $Data = $_.data
    $ExpectedStatus = $_.expect.status
    $ExpectedUrl = $_.expect.url

    Write-Host "  $Method $Url -> $ExpectedStatus $ExpectedUrl"

    $Request = [System.Net.HttpWebRequest]::Create($Url)
    $Request.AllowAutoRedirect = $true
    $Request.Method = $Method
    if ($Request.Method -eq 'POST')
    {
      $Request.ContentType = "application/x-www-form-urlencoded"
      $Stream = $Request.GetRequestStream()
      $Encoded = [System.Text.Encoding]::UTF8.GetBytes($Data)
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
        throw ("Expected HTTP status code $ExpectedStatus, but got $Status")
      }

      if ($Url -ne $ExpectedUrl)
      {
        throw ("Expected location $ExpectedUrl, but got $Url")
      }
    }
    finally
    {
      $Response.Close()
    }
  }
}
