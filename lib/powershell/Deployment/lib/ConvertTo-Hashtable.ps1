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

    if ($InputObject -is [string] -and
        ($InputObject -eq '~' -or
         $InputObject -eq 'null'))
    {
      Return $null
    }

    if ($InputObject -is [ValueType] -or
        $InputObject -is [string] -or
        $InputObject -is [hashtable])
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

    if ($InputObject -is [System.Collections.IEnumerable])
    {
      $Collection = @(
        foreach ($Object in $InputObject)
        {
          ConvertTo-Hashtable $Object
        }
      )

      Write-Output -NoEnumerate $Collection
    }
    elseif ($InputObject -is [psobject])
    {
      $Hash = @{}

      foreach ($Property in $InputObject.PSObject.Properties)
      {
        $Hash[$Property.Name] = ConvertTo-Hashtable $Property.Value
      }

      $Hash
    }
    else
    {
      $InputObject
    }
  }
}
