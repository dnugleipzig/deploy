function Set-Permissions
{
  [CmdletBinding()]
  param (
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $RootPath,
    [Parameter(Position = 1, Mandatory = $false)]
    [hashtable] $Permissions
  )

  if ($Permissions -eq $null -or $Permissions.Count -eq 0)
  {
    Return
  }

  Set-Variable -Name SidToken -Value 'sid://' -Option Constant

  $RootPath = [System.IO.Path]::GetFullPath($RootPath)

  $Permissions.GetEnumerator() | Sort-Object Name | ForEach-Object {
    $Path = [System.IO.Path]::Combine($RootPath, $_.Key)

    if ($(Test-Path -Path $Path -PathType Container) -ne $true)
    {
      New-Item $Path -Type Directory | Out-Null
    }

    Write-Host "Permissions for $Path"

    $Acl = New-Object System.Security.AccessControl.DirectorySecurity

    $_.Value.GetEnumerator() | ForEach-Object {
      $Rights = $_.Key

      $_.Value.GetEnumerator() | ForEach-Object {
        $Identity = $_
        if ($Identity.StartsWith($SidToken, [System.StringComparison]::OrdinalIgnoreCase))
        {
          $Identity = ConvertTo-UserName([System.Security.Principal.WellKnownSidType] $_.Substring($SidToken.Length))
        }

        Write-Host "  ${Identity}: $Rights"

        $Parameters = $Identity, `
          [System.Security.AccessControl.FileSystemRights]::$Rights, `
          [System.Security.AccessControl.InheritanceFlags] 'ContainerInherit, ObjectInherit', `
          [System.Security.AccessControl.PropagationFlags]::None, `
          [System.Security.AccessControl.AccessControlType]::Allow

        $Ace = New-Object System.Security.AccessControl.FileSystemAccessRule $Parameters

        $Acl.AddAccessRule($Ace)
      }
    }

    Set-Acl -Path $Path -AclObject $Acl
  }

  # Remove inherited permissions from root.
  Write-Host "Removing inherited ACEs from $RootPath"
  $Inherited = Get-Acl -Path $RootPath
  $Inherited.SetAccessRuleProtection($true, $false)
  Set-Acl -Path $RootPath -AclObject $Inherited
}
