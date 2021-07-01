function Get-ADNestedGroupMembers_Main {
    param(
        [Parameter(Position = 0, Mandatory)]
        [Microsoft.ActiveDirectory.Management.ADGroup]$Group,
        [Parameter(Position = 1)]
        [pscredential]$Credential
    )

    $adCmdletsSplat = @{
        "ErrorAction" = "Stop";
    }
    
    if ($null -ne $Credential) {
        $adCmdletsSplat.Add("Credential", $Credential)
    }

    Write-Verbose "Getting group memberships for '$($Group.Name)'."
    $groupMembersObj = $Group | Get-ADGroupMember @adCmdletsSplat
    $groupMembersRecursiveObj = $Group | Get-ADGroupMember @adCmdletsSplat -Recursive

    $allGroupUsers = foreach ($userItem in ($groupMembersObj | Where-Object { $PSItem.ObjectClass -eq "user" })) {
        ($userItem | Get-ADUser @adCmdletsSplat).UserPrincipalName
    }
    $allNestedGroupUsers = foreach ($userItem in ($groupMembersRecursiveObj | Where-Object { $PSItem.ObjectClass -eq "user" })) {
        ($userItem | Get-ADUser @adCmdletsSplat).UserPrincipalName
    }

    $nestedGroups = $groupMembersObj | Where-Object { $PSItem.ObjectClass -eq "group" }
    $nestedGroupsCount = ($nestedGroups | Measure-Object).Count
    Write-Verbose "'$($Group.Name)' nested group count - $($nestedGroupsCount.ToString("00"))"

    $hasNestedGroups = $null
    $nestedGroupsResolved = [System.Collections.Generic.List[ActiveDirectoryGroup]]::new()
    switch ($nestedGroupsCount -eq 0) {
        $true {
            $hasNestedGroups = $false
            break
        }
        
        Default {
            $hasNestedGroups = $true

            foreach ($groupItem in $nestedGroups) {
                $groupAdObj = $groupItem | Get-ADGroup @adCmdletsSplat

                $nestedGroupItems = GetNestedGroupMemberships -Group $groupAdObj @adCmdletsSplat
                $nestedGroupsResolved.Add($nestedGroupItems)
            }
            break
        }
    }

    return [ActiveDirectoryGroup]@{
        "Group"                 = $Group.DistinguishedName;
        "GroupMembers"          = $allGroupUsers;
        "RecursiveGroupMembers" = $allNestedGroupUsers;
        "HasNestedGroups"       = $hasNestedGroups;
        "NestedGroups"          = $nestedGroupsResolved;
    }
}