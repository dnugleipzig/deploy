function ConvertTo-AbsolutePath
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [object] $Path
  )

  begin
  {
    Set-Variable -Name PathToken -Value 'absolute-path://' -Option Constant
  }

  process
  {
    if($Path -isnot [string])
    {
      Return $Path
    }

    if (!$Path.StartsWith($PathToken, [System.StringComparison]::OrdinalIgnoreCase))
    {
      Return $Path
    }

    [System.IO.Path]::GetFullPath($Path.Substring($PathToken.Length))
  }
}
