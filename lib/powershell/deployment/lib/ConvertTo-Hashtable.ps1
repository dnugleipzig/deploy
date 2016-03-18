function ConvertTo-Hashtable
{
  [CmdletBinding()]
  param (
    [Parameter(ValueFromPipeline)]
    $InputObject
  )

  process
  {
    if ($InputObject -eq $null)
    {
      Return $null
    }

    if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
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
        $Hash[$Property.Name] = ConvertTo-Hashtable($Property.Value)
      }

      $hash
    }
    else
    {
      $InputObject
    }
  }
}
