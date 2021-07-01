class SpoMigrationManagerTaskItemSettings {
    [bool]$MigrateHiddenItems
    [string]$MigrateItemsCreatedAfter
    [string]$MigrateItemsModifiedAfter
    [string]$SkipFilesWithExtensions
    [bool]$MigrateOneNoteNotebook
}

class SpoMigrationManagerTaskItem {
    [string]$SourcePath
    [string]$TargetPath
    [string]$TargetList
    [string]$TargetListRelativePath
    #[SpoMigrationManagerTaskItemSettings]$Settings
}

class SpoMigrationManagerTasks {
    [SpoMigrationManagerTaskItem[]]$Tasks
}