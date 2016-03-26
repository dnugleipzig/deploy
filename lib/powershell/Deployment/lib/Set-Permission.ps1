function Set-Permission
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $Path,
    [Parameter(Position = 1, Mandatory = $true)]
    [AllowNull()]
    [hashtable] $Permissions
  )

  if (!$(Test-Path -Path $Path -PathType Container))
  {
    New-Item -Path $Path -Type Directory | Out-Null
  }

  if ($null -eq $Permissions -or $Permissions.Count -eq 0)
  {
    Return
  }

  $Path = Resolve-Path -Path $Path
  "Permissions for $Path" | Out-Host

  $Permissions.GetEnumerator() | ForEach-Object {
    $Acl = New-Object System.Security.AccessControl.DirectorySecurity

    $Rights = $_.Key

    $_.Value | ForEach-Object {
      $Identity = ConvertTo-UserName $_

      "  ${Identity}: $Rights" | Out-Host

      $Parameters = $Identity, `
        [System.Security.AccessControl.FileSystemRights]::$Rights, `
        [System.Security.AccessControl.InheritanceFlags] 'ContainerInherit, ObjectInherit', `
        [System.Security.AccessControl.PropagationFlags]::None, `
        [System.Security.AccessControl.AccessControlType]::Allow

      $Ace = New-Object System.Security.AccessControl.FileSystemAccessRule $Parameters

      $Acl.AddAccessRule($Ace)
    }

    Set-Acl -Path $Path -AclObject $Acl
  }
}
