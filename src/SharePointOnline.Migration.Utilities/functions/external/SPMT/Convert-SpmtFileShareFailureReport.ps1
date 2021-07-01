function Convert-SpmtFileShareFailureReport {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory, ParameterSetName = "ScanFolderPath")]
        [string]$ScanFolderPath,
        [Parameter(Position = 0, Mandatory, ParameterSetName = "ReportPath")]
        [string]$ReportPath,
        [Parameter(Position = 1)]
        [int]$IncrementRound = 1
    )

    $resolvedReportPath = $null
    switch ($PSCmdlet.ParameterSetName) {
        "ReportPath" {
            $resolvedReportPath = (Resolve-Path -Path $ReportPath -ErrorAction "Stop").Path
            break
        }

        Default {
            $resolvedScanFolderPath = (Resolve-Path -Path $ScanFolderPath -ErrorAction "Stop").Path
            if ((Get-Item -Path $resolvedScanFolderPath).Attributes -eq [System.IO.FileAttributes]::Directory) {
                Write-Verbose "'$($resolvedScanFolderPath)' is a valid directory."
            }
            else {
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        [System.IO.FileFormatException]::new("'$($resolvedScanFolderPath)' is not a valid directory."),
                        "ScanFolderPathIsNotADirectory",
                        [System.Management.Automation.ErrorCategory]::InvalidOperation,
                        $resolvedScanFolderPath
                    )
                )
            }

            $scanFolderReportPath = Join-Path -Path $resolvedScanFolderPath -ChildPath "Report\"

            $taskReportFolder = Get-ChildItem -Path $scanFolderReportPath | Where-Object { ($PSItem.Attributes -eq [System.IO.FileAttributes]::Directory) -and ($PSItem.Name -like "TaskReport_*") }

            switch (($taskReportFolder | Measure-Object).Count) {
                { $PSItem -gt 1 } {
                    $PSCmdlet.ThrowTerminatingError(
                        [System.Management.Automation.ErrorRecord]::new(
                            [System.Exception]::new("'There are too many 'TaskReport_*' folders in '$($scanFolderReportPath)'."),
                            "TooManyTaskReports",
                            [System.Management.Automation.ErrorCategory]::InvalidOperation,
                            $taskReportFolder
                        )
                    )
                    break
                }

                { $PSItem -eq 0 } {
                    $PSCmdlet.ThrowTerminatingError(
                        [System.Management.Automation.ErrorRecord]::new(
                            [System.Exception]::new("'There isn't a 'TaskReport_*' folder in '$($scanFolderReportPath)'."),
                            "NoTaskReports",
                            [System.Management.Automation.ErrorCategory]::InvalidOperation,
                            $scanFolderReportPath
                        )
                    )
                    break
                }
            }
        
            $resolvedReportPath = Join-Path -Path $taskReportFolder.FullName -ChildPath "ItemFailureReport_R$($IncrementRound).csv" -Resolve -ErrorAction "Stop"
            break
        }
    }

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

    $reportItemData = Import-Csv -Path $resolvedReportPath
    foreach ($reportItem in $reportItemData) {
        $convertedItem = [SharePointOnline.Migration.Utilities.Models.SPMT.ReportItem]::new($reportItem)

        Write-Output $convertedItem
    }
}