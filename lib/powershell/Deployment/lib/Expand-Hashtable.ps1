function Expand-Hashtable
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $true)]
    [object] $InputObject,
    [Parameter(Position = 1, Mandatory = $false)]
    [array] $Path = @()
  )

  process
  {
    if ($null -eq $InputObject)
    {
      Return
    }

    $InputObject.GetEnumerator() | ForEach-Object {
      if($_.Value -is [ValueType] -or
         $_.Value -is [string] -or
         $null -eq $_.Value)
      {
        Return @{
          Path = $Path + $_.Key
          Value = $_.Value
        }
      }

      $_.Value | Expand-Hashtable -Path ($Path + $_.Key)
    }
  }
}
