Set-StrictMode -Version Latest

Get-ChildItem -Path $(Join-Path -Path $PSScriptRoot -ChildPath 'lib\*.ps1') -Exclude '*.Tests.ps1' -Recurse |
  ForEach-Object {
    . $_.FullName
  }

Export-ModuleMember -Function Invoke-Deployment, Exec
