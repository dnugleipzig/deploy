function Exec
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [scriptblock] $Command,
    [Parameter(Position = 1, Mandatory = $false)]
    [string] $ErrorMessage = ("Error executing command {0}, exit code {1}." -f $Command, $LastExitCode)
  )

  & $Command

  if ($LastExitCode -ne 0)
  {
    throw ("Exec: " + $ErrorMessage)
  }
}
