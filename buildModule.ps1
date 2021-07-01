$scriptRoot = $PSScriptRoot

$writeInfoSplat = @{
    "InformationAction" = "Continue";
}

Write-Information @writeInfoSplat -MessageData "|Step: Pre-build operations"
Write-Information @writeInfoSplat -MessageData "|`t| - Checking if 'build\' dir exists already."
$buildDir = Join-Path -Path $scriptRoot -ChildPath "build\"
if (Test-Path -Path $buildDir) {
    Write-Information @writeInfoSplat -MessageData "|`t|`t- 'build\' dir exists. Removing..."
    Remove-Item -Path $buildDir -Force -Recurse
}
Write-Information @writeInfoSplat -MessageData "|`t| - Creating 'build\' dir."
$null = New-Item -Path $scriptRoot -Name "build" -ItemType "Directory"

$moduleSrcPath = Join-Path -Path $scriptRoot -ChildPath "src\SharePointOnline.Migration.Utilities\"
$libSrcPath = Join-Path -Path $scriptRoot -ChildPath "src\SharePointOnline.Migration.Utilities.Lib\"

Write-Information @writeInfoSplat -MessageData "| Step: Copy module source to 'build\"
Write-Information @writeInfoSplat -MessageData "|`t| - Copying files..."
Copy-Item -Path $moduleSrcPath -Destination $buildDir -Recurse

$moduleBuildPath = Join-Path -Path $buildDir -ChildPath "SharePointOnline.Migration.Utilities\"

Write-Information @writeInfoSplat -MessageData "| Step: Compile class library"
Write-Information @writeInfoSplat -MessageData "|`t| - Compiling..."
dotnet clean --nologo "$($libSrcPath)"
dotnet publish --nologo --configuration "Release" "$($libSrcPath)"


Write-Information @writeInfoSplat -MessageData "| `t | - Copying compiled DLL to 'build\'..."
$compiledLibPath = Join-Path -Path $libSrcPath -ChildPath "bin\Release\net5.0\publish\SharePointOnline.Migration.Utilities.Lib.dll"
Copy-Item -Path $compiledLibPath -Destination $moduleBuildPath -Force

Write-Information @writeInfoSplat -MessageData "| Build complete."

$builtModuleItem = Get-Item -Path $moduleBuildPath
return $builtModuleItem