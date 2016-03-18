$Functions = Get-ChildItem -Path $(Join-Path -Path $PSScriptRoot -ChildPath 'lib\*.ps1') -Recurse | `
  ForEach-Object {
      . $_.FullName | Out-Null
      $Name = Split-Path -Leaf -Path $_.FullName
      [System.IO.Path]::GetFileNameWithoutExtension($Name)
  }

Export-ModuleMember -Function $Functions -Cmdlet '*' -Alias '*'
