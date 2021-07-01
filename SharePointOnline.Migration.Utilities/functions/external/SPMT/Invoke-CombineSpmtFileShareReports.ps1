function Invoke-CombineSpmtFileShareReports {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, Mandatory, ParameterSetName = "ScanFolderPath")]
        [string]$ScanFolderPath,
        [Parameter(Position = 0, Mandatory, ParameterSetName = "ReportsPath")]
        [string]$ReportsPath,
        [Parameter(Position = 1)]
        [int]$IncrementRound = 1
    )

    $resolvedReportsPath = $null
    switch ($PSCmdlet.ParameterSetName) {
        "ReportsPath" {
            $resolvedReportsPath = (Resolve-Path -Path $ReportsPath -ErrorAction "Stop").Path
            if ((Get-Item -Path $resolvedReportsPath).Attributes -eq [System.IO.FileAttributes]::Directory) {
                Write-Verbose "'$($resolvedReportsPath)' is a valid directory."
            }
            else {
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        [System.IO.FileFormatException]::new("'$($resolvedReportsPath)' is not a valid directory."),
                        "ReportsPathIsNotADirectory",
                        [System.Management.Automation.ErrorCategory]::InvalidOperation,
                        $resolvedReportsPath
                    )
                )
            }
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

                Default {
                    $resolvedReportsPath = $taskReportFolder
                    break
                }
            }
            break
        }
    }

    $itemReportFiles = [System.Collections.Generic.List[System.IO.FileInfo]](Get-ChildItem -Path $resolvedReportsPath | Where-Object { ($PSItem.Extension -eq ".csv") -and ($PSItem.Name -like "ItemReport_R$($IncrementRound)*") })

    $itemReportFiles.Sort(
        [SharePointOnline.Migration.Utilities.Models.Files.FileInfoDateTimeComparer]::new()
    )

    if ($null -eq $itemReportFiles) {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                [System.IO.FileFormatException]::new("No files matching 'ItemReport_R$($IncrementRound).csv' or 'ItemReport_R$($IncrementRound)_nnn.csv' were found in the reports path."),
                "ReportsPathDoesNotHaveReportFiles",
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $resolvedReportsPath
            )
        )
    }

    $reportItemList = [System.Collections.Generic.List[SharePointOnline.Migration.Utilities.Models.SPMT.ReportItem]]::new()
    Write-Warning "Now processing each report file. This may take a while and memory usage for this 'pwsh.exe' process might spike."
    foreach ($itemReportFile in $itemReportFiles) {
        if ($PSCmdlet.ShouldProcess($itemReportFile.Name, "Import CSV data")) {
            $reportData = Import-Csv -Path $itemReportFile.FullName

            foreach ($reportItem in $reportData) {
                $reportItemList.Add(
                    [SharePointOnline.Migration.Utilities.Models.SPMT.ReportItem]::new($reportItem)
                )
            }

            $reportData = $null

            $null = [System.GC]::Collect()
        }
    }

    return $reportItemList
}