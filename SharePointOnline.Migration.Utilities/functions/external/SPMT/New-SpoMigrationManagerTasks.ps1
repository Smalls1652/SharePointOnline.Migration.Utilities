function New-SpoMigrationManagerTasks {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [string]$InputFilePath,
        [Parameter(Position = 1, Mandatory)]
        [string]$SpoUri,
        [Parameter(Position = 2)]
        [string]$SpoList = "Documents"
        <#
    [Parameter(Position = 3)]
    [switch]$MoveHiddenItems,
    [Parameter(Position = 4)]
    [datetime]$OnlyItemsCreatedAfter,
    [Parameter(Position = 5)]
    [datetime]$OnlyItemsModifiedAfter,
    [Parameter(Position = 6)]
    [switch]$MoveOneNoteNotebook
    #>
    )

    $resolvedInputFilePath = (Resolve-Path -Path $InputFilePath -ErrorAction "Stop").Path
    $inputFileData = [SharePointOnline.Migration.Utilities.Models.Files.FolderItemDetails[]](Import-Csv -Path $resolvedInputFilePath)

    $createdItemsAfterDateString = $null
    switch ($null -eq $OnlyItemsCreatedAfter) {
        $true {
            $createdItemsAfterDateString = $null
            break
        }

        Default {
            $createdItemsAfterDateString = $OnlyItemsCreatedAfter.ToString("yyyy-MM-dd")
            break
        }
    }

    $modifiedItemsAfterDateString = $null
    switch ($null -eq $OnlyItemsModifiedAfter) {
        $true {
            $modifiedItemsAfterDateString = $null
            break
        }

        Default {
            $modifiedItemsAfterDateString = $OnlyItemsModifiedAfter.ToString("yyyy-MM-dd")
            break
        }
    }

    $taskItemsList = [System.Collections.Generic.List[SharePointOnline.Migration.Utilities.Models.SPMT.MigrationManagerTaskItem]]::new()
    foreach ($folderToMigrate in $inputFileData) {
        $taskItemsList.Add(
            [SharePointOnline.Migration.Utilities.Models.SPMT.MigrationManagerTaskItem]@{
                "SourcePath"             = $folderToMigrate.FullName;
                "TargetPath"             = $SpoUri;
                "TargetList"             = $SpoList;
                "TargetListRelativePath" = $folderToMigrate.Name;
            }
        )
    }

    [SharePointOnline.Migration.Utilities.Models.SPMT.MigrationManagerTasks]@{
        "Tasks" = $taskItemsList
    }
}