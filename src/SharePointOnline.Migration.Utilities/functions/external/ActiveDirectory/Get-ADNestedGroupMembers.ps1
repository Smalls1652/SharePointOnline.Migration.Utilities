function Get-ADNestedGroupMembers {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [Microsoft.ActiveDirectory.Management.ADGroup]$Group,
        [Parameter(Position = 1)]
        [pscredential]$Credential,
        [Parameter(Position = 2)]
        [string]$Server
    )

    $adCmdletsSplat = @{
        "ErrorAction" = "Stop";
    }
    
    if ($null -ne $Credential) {
        $adCmdletsSplat.Add("Credential", $Credential)
    }

    if ($null -ne $Server) {
        $adCmdletsSplat.Add("Server", $Server)
    }

    Write-Verbose "Getting group memberships for '$($Group.Name)'."
    $groupMembersObj = $Group | Get-ADGroupMember @adCmdletsSplat
    $groupMembersRecursiveObj = $Group | Get-ADGroupMember @adCmdletsSplat -Recursive

    $allGroupUsers = [System.Collections.Generic.List[string]]::new()
    foreach ($userItem in ($groupMembersObj | Where-Object { $PSItem.ObjectClass -eq "user" })) {
        $item = ($userItem | Get-ADUser @adCmdletsSplat).UserPrincipalName
        $allGroupUsers.Add($item)
    }

    $allNestedGroupUsers = [System.Collections.Generic.List[string]]::new()
    foreach ($userItem in ($groupMembersRecursiveObj | Where-Object { $PSItem.ObjectClass -eq "user" })) {
        $item = ($userItem | Get-ADUser @adCmdletsSplat).UserPrincipalName
        $allNestedGroupUsers.Add($item)
    }

    $nestedGroups = $groupMembersObj | Where-Object { $PSItem.ObjectClass -eq "group" }
    $nestedGroupsCount = ($nestedGroups | Measure-Object).Count
    Write-Verbose "'$($Group.Name)' nested group count - $($nestedGroupsCount.ToString("00"))"

    $hasNestedGroups = $null
    $nestedGroupsResolved = [System.Collections.Generic.List[SharePointOnline.Migration.Utilities.Models.ActiveDirectory.ActiveDirectoryGroup]]::new()
    switch ($nestedGroupsCount -eq 0) {
        $true {
            $hasNestedGroups = $false
            break
        }
        
        Default {
            $hasNestedGroups = $true

            foreach ($groupItem in $nestedGroups) {
                $groupAdObj = $groupItem | Get-ADGroup @adCmdletsSplat

                $nestedGroupItems = Get-ADNestedGroupMembers -Group $groupAdObj @adCmdletsSplat
                $nestedGroupsResolved.Add($nestedGroupItems)
            }
            break
        }
    }

    try {
        $groupObj = [SharePointOnline.Migration.Utilities.Models.ActiveDirectory.ActiveDirectoryGroup]@{
            "Group"                 = $Group.Name;
            "GroupMembers"          = $allGroupUsers;
            "RecursiveGroupMembers" = $allNestedGroupUsers;
            "HasNestedGroups"       = $hasNestedGroups;
            "NestedGroups"          = $nestedGroupsResolved;
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                [System.Exception]::new("An error occurred while creating the return object."),
                "ErrorCreatingObject",
                [System.Management.Automation.ErrorCategory]::InvalidType,
                @{
                    "Group" = $Group.Name;
                    "GroupMembers" = $allGroupUsers;
                    "RecursiveGroupMembers" = $allNestedGroupUsers;
                    "HasNestedGroups" = $hasNestedGroups;
                    "NestedGroups" = $nestedGroupsResolved;
                }
            )
        )
    }

    return $groupObj

    #Get-ADNestedGroupMembers_Main @PSBoundParameters
}