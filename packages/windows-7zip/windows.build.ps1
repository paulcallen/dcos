$ErrorActionPreference = "stop"
new-item -itemtype directory "c:\7zip"
& cmd.exe /c start /wait msiexec /i c:\pkg\src\windows-7zip\7z1801-x64.msi INSTALLDIR="c:\7zip" /qn
if ($LASTEXITCODE -ne 0) {
    throw "instlal 7zip failed"
}
rename-item c:\7zip\License.txt c:\7zip\7zip_licence.txt
rename-item c:\7zip\History.txt c:\7zip\7zip_history.txt
rename-item c:\7zip\descript.ion c:\7zip\7zip_descript.ion
rename-item c:\7zip\readme.txt c:\7zip\7zip_readme.txt
new-item -itemtype directory "$env:PKG_PATH\bin"
copy-item -Recurse "c:\7zip\*" "$env:PKG_PATH\bin"
