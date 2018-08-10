$ErrorActionPreference = "stop"

$SYSTEMCTL_WIN_DIR="c:\pkg\src\systemctl-win\systemctl-win"

New-Item -ItemType Directory -Force "$env:PKG_PATH\bin\"
nuget restore $SYSTEMCTL_WIN_DIR\systemctl-win.sln	
if ($LASTEXITCODE -ne 0) {
    throw "nuget restore systemctl-win.sln failed in windows-systemctl build"
}
msbuild $SYSTEMCTL_WIN_DIR\systemctl-win.sln /p:configuration=release	
if ($LASTEXITCODE -ne 0) {
    throw "nuget restore systemctl-win.sln failed in windows-systemctl build"
}
new-item -itemtype directory "$env:PKG_PATH\bin" -force
copy-item $SYSTEMCTL_WIN_DIR\x64\release\systemctl.exe -destination "$env:PKG_PATH\bin"	
copy-item $SYSTEMCTL_WIN_DIR\x64\release\systemd-exec.exe -destination "$env:PKG_PATH\bin"
