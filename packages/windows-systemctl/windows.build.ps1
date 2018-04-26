$ErrorActionPreference = "stop"
copy-item -recurse  "c:\pkg\src\systemctl-win" -destination "c:\"
push-location "c:\systemctl-win"
nuget restore systemctl-win.sln
msbuild systemctl-win.sln /p:configuration=release
new-item -itemtype directory "$env:PKG_PATH\bin"
copy-item "C:\systemctl-win\x64\release\systemctl.exe" -destination "$env:PKG_PATH\bin"

