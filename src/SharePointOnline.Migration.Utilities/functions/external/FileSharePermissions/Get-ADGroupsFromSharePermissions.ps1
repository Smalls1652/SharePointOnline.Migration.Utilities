function Get-ADGroupsFromSharePermissions {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$ReportPath,
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

    $activeDirectoryDomainName = (Get-ADDomain @adCmdletsSplat).NetBIOSName

    $resolvedReportPath = (Resolve-Path -Path $ReportPath -ErrorAction "Stop").Path

    $reportItemObj = Get-Item -Path $resolvedReportPath

    switch ($reportItemObj.Extension -eq ".csv") {
        $true {
            Write-Verbose "'$($resolvedReportPath)' is a valid CSV file."
            break
        }

        Default {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    [System.IO.FileFormatException]::new("'$($resolvedReportPath)' is not a valid file."),
                    "ReportsPathIsNotADirectory",
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $reportItemObj
                )
            )
            break
        }
    }

    Write-Verbose "Importing CSV file data."
    $importedPermissionReport = (Import-Csv -Path $resolvedReportPath -ErrorAction "Stop") | ForEach-Object { [SharePointOnline.Migration.Utilities.Models.Files.FileSharePermissionItem]$PSItem }
    $uniqueImportedPermissions = $importedPermissionReport | Select-Object -Property "AdObject" -Unique | Sort-Object -Property "AdObject" | Where-Object { $PSItem.AdObject -like "$($activeDirectoryDomainName)\*" }

    Write-Verbose "Clearing unnecessary data."
    [System.GC]::Collect()

    Write-Verbose "Looking for groups in list."
    foreach ($permissionItem in $uniqueImportedPermissions) {
        $objectName = $permissionItem.AdObject

        $objectName = $objectName -replace "$($activeDirectoryDomainName)\\", ""

        $adObjectData = Get-ADObject @adCmdletsSplat -Filter "SamAccountName -eq '$($objectName)'"

        if ($adObjectData.ObjectClass -eq "group") {
            Write-Verbose "Group found: $($adObjectData.DistinguishedName)"
            $adObjectData | Get-ADGroup
        }
    }
}