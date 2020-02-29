function ConvertTo-Hashtable
{
  [CmdletBinding()]
  [OutputType([hashtable])]
  param (
    [Parameter(ValueFromPipeline = $true)]
    $InputObject
  )

  process
  {
    if ($null -eq $InputObject)
    {
      Return
    }

    if ($InputObject -is [ValueType] -or
        $InputObject -is [string])
    {
      if ($InputObject -is [string])
      {
        $Parsed = $null
        if([int]::TryParse($InputObject, [ref]$Parsed))
        {
          Return $Parsed
        }
        if([bool]::TryParse($InputObject, [ref]$Parsed))
        {
          Return $Parsed
        }
      }

      Return $InputObject
    }

    if ($InputObject -is [System.Collections.IDictionary])
    {
      $Hash = @{}

      $InputObject.GetEnumerator() | ForEach-Object {
        $Hash[$_.Key] = ConvertTo-Hashtable -InputObject $_.Value
      }

      $Hash
    }
    elseif ($InputObject -is [System.Collections.IEnumerable])
    {
      $Collection = @(
        foreach ($Object in $InputObject)
        {
          ConvertTo-Hashtable -InputObject $Object
        }
      )

      Write-Output $Collection -NoEnumerate
    }
    elseif ($InputObject -is [psobject])
    {
      $Hash = @{}

      foreach ($Property in $InputObject.PSObject.Properties)
      {
        $Hash[$Property.Name] = ConvertTo-Hashtable -InputObject $Property.Value
      }

      $Hash
    }
    else
    {
      $InputObject
    }
  }
}
