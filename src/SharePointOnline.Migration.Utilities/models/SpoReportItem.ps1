class SpoReportItem {
    [string]$DestinationPath
    [string]$DestinationItemId
    [string]$MigrationAgentName
    [string]$ErrorCode
    [string]$Extension
    [string]$IncrementalRound
    [string]$ItemName
    [int]$ItemSizeInGB
    [string]$Message
    [string]$MigrationJobId
    [string]$PackageNumber
    [string]$ResultCategory
    [string]$ServerErrorMessage
    [string]$SourcePath
    [string]$SourceItemId
    [string]$Status
    [string]$TaskId
    [string]$Type

    SpoReportItem([pscustomobject] $inputItem) {
        $this.DestinationPath = $inputItem.'Destination'
        $this.DestinationItemId = $inputItem.'Destination item ID'
        $this.MigrationAgentName = $inputItem.'Device name'
        $this.ErrorCode = $inputItem.'Error code'
        $this.Extension = $inputItem.'Extension'
        $this.IncrementalRound = $inputItem.'Incremental round'
        $this.ItemName = $inputItem.'Item name'
        $this.ItemSizeInGB = ([System.Math]::Round(($inputItem.'Item size (bytes)' / 1GB), 2))
        $this.Message = $inputItem.'Message'
        $this.MigrationJobId = $inputItem.'MigrationJobId'
        $this.PackageNumber = $inputItem.'Package number'
        $this.ResultCategory = $inputItem.'Result category'
        $this.ServerErrorMessage = $inputItem.'Server error message'
        $this.SourcePath = $inputItem.'Source'
        $this.SourceItemId = $inputItem.'Source item ID'
        $this.Status = $inputItem.'Status'
        $this.TaskId = $inputItem.'Task ID'
        $this.Type = $inputItem.'Type'
    }
}