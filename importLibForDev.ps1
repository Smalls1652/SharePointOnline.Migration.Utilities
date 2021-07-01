$scriptRoot = $PSScriptRoot

$libPath = Join-Path -Path $scriptRoot -ChildPath "src\SharePointOnline.Migration.Utilities.Lib\bin\Release\net5.0\publish\SharePointOnline.Migration.Utilities.Lib.dll"

[System.Reflection.Assembly]::LoadFile($libPath)