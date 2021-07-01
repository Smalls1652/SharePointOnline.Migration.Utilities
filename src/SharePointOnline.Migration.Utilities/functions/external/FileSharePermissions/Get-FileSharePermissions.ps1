function Get-FileSharePermissions {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$FileSharePath
    )

    $resolvedFileSharePath = (Resolve-Path -Path $FileSharePath -ErrorAction "Stop").Path

    $foldersInShare = Get-ChildItem -Directory -Path $resolvedFileSharePath -Recurse -Force

    $permissionsFound = [System.Collections.Generic.List[SharePointOnline.Migration.Utilities.Models.Files.FileSharePermissionItem]]::new()

    foreach ($folderItem in $foldersInShare) {
        Write-Verbose "Processing '$($folderItem.FullName)'"
        $folderAcl = Get-Acl -Path $folderItem.FullName

        foreach ($aclItem in $folderAcl.Access) {
            $folderPermissions = [SharePointOnline.Migration.Utilities.Models.Files.FileSharePermissionItem]@{
                "FolderPath"  = $folderItem.FullName;
                "AdObject"    = $aclItem.IdentityReference;
                "Permissions" = $aclItem.FileSystemRights;
                "IsInherited"   = $aclItem.IsInherited
            }
            $permissionsFound.Add($folderPermissions)
        }
    }

    return $permissionsFound
}