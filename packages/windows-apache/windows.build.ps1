$ErrorActionPreference = "stop"
. c:\opt\mesosphere\environment.export.ps1
New-Item -ItemType Directory -Force "$env:PKG_PATH\bin\"
& 7z x "c:\pkg\src\windows-apache\httpd-2.4.33-o102o-x64-vc14-r2.zip" "-o$env:PKG_PATH\bin\"
if ($LASTEXITCODE -ne 0)
{
    throw "failed to unpack apache"
}