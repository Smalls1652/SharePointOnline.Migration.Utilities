$scriptRoot = $PSScriptRoot

$modulePath = Join-Path -Path $scriptRoot -ChildPath "SharePointOnline.Migration.Utilities\"
$libPath = Join-Path -Path $scriptRoot -ChildPath "SharePointOnline.Migration.Utilities.Lib\"

dotnet clean --nologo "$($libPath)"
dotnet publish --nologo --configuration "Release" "$($libPath)"

$compiledLibPath = Join-Path -Path $libPath -ChildPath "bin\Release\net5.0\publish\SharePointOnline.Migration.Utilities.Lib.dll"

Copy-Item -Path $compiledLibPath -Destination $modulePath -Force