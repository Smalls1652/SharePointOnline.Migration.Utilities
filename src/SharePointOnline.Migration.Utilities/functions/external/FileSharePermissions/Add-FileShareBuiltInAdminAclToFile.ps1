function Add-FileShareBuiltInAdminAclToFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$FilePath,
        [Parameter(Position = 1)]
        [pscredential]$TakeOwnerShipAdminCreds
    )

    Write-Verbose "Processing file at '$($FilePath)'."
    $resolvedFilePath = (Resolve-Path -Path $FilePath -ErrorAction "Stop").Path

    $adminAclRule = [System.Security.AccessControl.FileSystemAccessRule]::new(
        "BUILTIN\Administrators",
        [System.Security.AccessControl.FileSystemRights]::FullControl,
        [System.Security.AccessControl.InheritanceFlags]::None,
        [System.Security.AccessControl.PropagationFlags]::None,
        [System.Security.AccessControl.AccessControlType]::Allow
    )

    if ($null -ne $TakeOwnerShipAdminCreds) {
        if ($PSCmdlet.ShouldProcess($FilePath, "Take ownership of file")) {
            Invoke-Command -ComputerName "localhost" -Credential $TakeOwnerShipAdminCreds -ArgumentList @($FilePath) -ScriptBlock {
            $tmpFile = New-TemporaryFile

            $null = Start-Process -FilePath "takeown" -ArgumentList @("/A", "/f `"$($args[0])`"") -NoNewWindow -Wait -RedirectStandardOutput $tmpFile.FullName

            Remove-Item -Path $tmpFile.FullName -Force
            }
        }
    }

    $fileAcl = Get-Acl -Path $FilePath

    Write-Verbose "Looking for any existing rules for the 'BUILTIN\Administators' group."
    $existingBuiltInAdminAcls = $fileAcl.Access | Where-Object { $PSItem.IdentityReference.Value -eq "BUILTIN\Administrators" }

    if ($null -ne $existingBuiltInAdminAcls) {
        Write-Verbose "Removing existing rules found."
        foreach ($existingRule in $existingBuiltInAdminAcls) {
            $null = $fileAcl.RemoveAccessRule($existingRule)
        }
    }

    Write-Verbose "Adding full control rule for the 'BUILTIN\Administators' group."
    $null = $fileAcl.AddAccessRule($adminAclRule)

    if ($PSCmdlet.ShouldProcess($FilePath, "Apply new ACL rules")) {
        $fileAcl | Set-Acl -Path $FilePath
    }
}