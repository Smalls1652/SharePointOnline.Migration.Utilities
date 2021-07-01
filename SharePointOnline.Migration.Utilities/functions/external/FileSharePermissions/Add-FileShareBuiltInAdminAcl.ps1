function Add-FileShareBuiltInAdminAcl {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$FolderPath,
        [Parameter(Position = 1)]
        [switch]$EntireFolder
    )

    $resolvedFolderPath = (Resolve-Path -Path $FolderPath -ErrorAction "Stop").Path

    $adminAclRule = [System.Security.AccessControl.FileSystemAccessRule]::new(
        "BUILTIN\Administrators",
        [System.Security.AccessControl.FileSystemRights]::FullControl,
        @([System.Security.AccessControl.InheritanceFlags]::ContainerInherit, [System.Security.AccessControl.InheritanceFlags]::ObjectInherit),
        [System.Security.AccessControl.PropagationFlags]::None,
        [System.Security.AccessControl.AccessControlType]::Allow
    )

    $foldersNotFixed = [System.Collections.Generic.List[pscustomobject]]::new()

    switch ($EntireFolder) {
        $true {
            $errorsOccurred = $null
            $childFolders = Get-ChildItem -Path $resolvedFolderPath -Recurse -Force -ErrorAction "SilentlyContinue" -ErrorVariable "errorsOccurred"

            foreach ($errorItem in $errorsOccurred) {
                $errorFolder = $errorItem.TargetObject
                Write-Warning "'$($errorFolder)' did not resolve correctly."
                Write-Warning "Attempting to add 'BUILTIN\Administrators' to the folder."
                $aclItem = Get-Acl -Path $errorFolder
            
                if ($PSCmdlet.ShouldProcess($errorFolder, "Add permissions")) {
                    $aclItem.AddAccessRule($adminAclRule)
                    $aclItem | Set-Acl -Path $errorFolder
            
                    try {
                        $null = Get-ChildItem -Path $errorFolder -Force -ErrorAction "Stop"
                    }
                    catch [System.UnauthorizedAccessException] {
                        $PSCmdlet.WriteError(
                            [System.Management.Automation.ErrorRecord]::new(
                                [System.Exception]::new("ACL change didn't resolve issue for folder."),
                                "FolderAccessStillDenied",
                                [System.Management.Automation.ErrorCategory]::PermissionDenied,
                                $errorFolder
                            )
                        )

                        $foldersNotFixed.Add(
                            [pscustomobject]@{
                                "FolderPath" = $errorFolder
                            }
                        )
                    }
                    catch {
                        $errorDetails = $PSItem
                        $PSCmdlet.WriteError($errorDetails)

                        $foldersNotFixed.Add(
                            [pscustomobject]@{
                                "FolderPath" = $errorFolder
                            }
                        )
                    }
                }
            }
            break
        }

        Default {
            try {
                $null = Get-ChildItem -Path $resolvedFolderPath -Force -ErrorAction "Stop"
                Write-Verbose "'$($resolvedFolderPath)' resolved correctly."
            }
            catch [System.UnauthorizedAccessException] {
                Write-Warning "'$($resolvedFolderPath)' did not resolve correctly."
                Write-Warning "Attempting to add 'BUILTIN\Administrators' to the folder."
                $aclItem = Get-Acl -Path $resolvedFolderPath
        
                if ($PSCmdlet.ShouldProcess($resolvedFolderPath, "Add permissions")) {
                    $aclItem.AddAccessRule($adminAclRule)
                    $aclItem | Set-Acl -Path $resolvedFolderPath
        
                    try {
                        $null = Get-ChildItem -Path $resolvedFolderPath -Force -ErrorAction "Stop"
                        Write-Verbose "'$($resolvedFolderPath)' resolves correctly now."
                    }
                    catch [System.UnauthorizedAccessException] {
                        $PSCmdlet.ThrowTerminatingError(
                            [System.Management.Automation.ErrorRecord]::new(
                                [System.Exception]::new("ACL change didn't resolve issue for folder."),
                                "FolderAccessStillDenied",
                                [System.Management.Automation.ErrorCategory]::PermissionDenied,
                                $FolderPath
                            )
                        )
                    }
                }
            }
            break
        }
    }

    if ($null -ne $foldersNotFixed) {
        Write-Output $foldersNotFixed
    }
}