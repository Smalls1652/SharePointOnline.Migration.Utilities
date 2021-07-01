<#
$moduleClasses = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "models\") -Recurse | Where-Object { $PSItem.Extension -eq ".ps1" }
foreach ($item in $moduleClasses) {
    . "$($item.FullName)"
}
#>

$internalFunctions = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "functions\internal\") -Recurse | Where-Object { $PSItem.Extension -eq ".ps1" }
foreach ($item in $internalFunctions) {
    . "$($item.FullName)"
}

$exportableFunctions = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath "functions\external\") -Recurse | Where-Object { $PSItem.Extension -eq ".ps1" }
foreach ($item in $exportableFunctions) {
    . "$($item.FullName)"
}