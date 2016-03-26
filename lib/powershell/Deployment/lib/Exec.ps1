function Exec
{
  [CmdletBinding()]
  param(
    [Parameter(Position = 0, Mandatory = $true)]
    [scriptblock] $Command
  )

  & $Command

  if ($LastExitCode -ne 0)
  {
    $Message = "Exec: Error executing command {0}, exit code {1}." -f $Command, $LastExitCode

    throw $Message
  }
}
