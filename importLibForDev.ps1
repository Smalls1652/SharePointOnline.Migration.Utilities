$scriptRoot = $PSScriptRoot

$moduleLibPath = Join-Path -Path $scriptRoot -ChildPath "SharePointOnline.Migration.Utilities\SharePointOnline.Migration.Utilities.Lib.dll"

[System.Reflection.Assembly]::LoadFile($moduleLibPath)