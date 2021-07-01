class ActiveDirectoryGroup {
    [string]$Group
    [string[]]$GroupMembers
    [string[]]$RecursiveGroupMembers
    [bool]$HasNestedGroups
    [ActiveDirectoryGroup[]]$NestedGroups
}