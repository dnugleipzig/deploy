function ConvertTo-PascalCase
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Value
  )

  process
  {
    $Parts = $Value.Split('_', [StringSplitOptions]::RemoveEmptyEntries) | ForEach-Object {
      [char]::ToUpperInvariant($_[0]) + $_.Substring(1, $_.Length - 1)
    }
    $Parts -Join ''
  }
}
