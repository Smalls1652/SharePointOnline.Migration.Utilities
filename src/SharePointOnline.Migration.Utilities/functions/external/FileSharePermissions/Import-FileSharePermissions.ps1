function Import-FileSharePermissions {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$ReportPath
    )

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
    $importedPermissionReport = [SharePointOnline.Migration.Utilities.Models.Files.FileSharePermissionItem[]](Import-Csv -Path $resolvedReportPath -ErrorAction "Stop")

    return $importedPermissionReport
}